defmodule MassaProxy.Server.GrpcServer do
  @moduledoc false
  require Logger

  alias MassaProxy.Util

  @grpc_template_path Path.expand("./templates/grpc_service.ex.eex", :code.priv_dir(:massa_proxy))
  @grpc_endpoint_template_path Path.expand(
                                 "./templates/grpc_endpoint.ex.eex",
                                 :code.priv_dir(:massa_proxy)
                               )

  def start(descriptors, entities), do: start_grpc(descriptors, entities)

  defp start_grpc(descriptors, entities) do
    {uSecs, _} =
      :timer.tc(fn ->
        with {:ok, descriptors} <- descriptors |> compile,
             {:ok, _} <- generate_services(entities),
             {:ok, _} <- generate_endpoints(entities) do
          start_proxy([])
        else
          _ -> Logger.error("Error during gRPC Server initialization")
        end

        :ok
      end)

    Logger.info("Started gRPC Server in #{uSecs / 1_000_000}ms")
  end

  defp compile(descriptors) do
    files =
      descriptors
      |> MassaProxy.Reflection.compile()

    for file <- files do
      result = Util.compile(file)
      Logger.debug("Compiled module: #{inspect(result)}")
    end

    {:ok, descriptors}
  end

  defp generate_services(entities) do
    for entity <- entities do
      name = Enum.join([Util.normalize_service_name(entity.service_name), "Service"], ".")
      services = Enum.at(entity.services, 0) |> Enum.at(0)

      methods =
        services.methods
        |> Flow.from_enumerable()
        |> Flow.map(&Util.normalize_mehod_name(&1.name))
        |> Enum.to_list()

      Logger.info("Generating Service #{name} with Methods: #{inspect(methods)}")

      mod =
        Util.get_module(
          @grpc_template_path,
          mod_name: name,
          name: name,
          methods: methods,
          handler: "MassaProxy.Server.Dispatcher",
          entity_type: entity.entity_type,
          persistence_id: entity.persistence_id
        )

      Logger.debug("Service defined: #{mod}")
      mod_compiled = Util.compile(mod)
      Logger.debug("Service compiled: #{inspect(mod_compiled)}")
    end

    {:ok, entities}
  end

  defp generate_endpoints(entities) do
    services =
      entities
      |> Flow.from_enumerable()
      |> Flow.map(
        &Enum.join([Util.normalize_service_name(&1.service_name), "Service.ProxyService"], ".")
      )
      |> Enum.to_list()

    mod =
      Util.get_module(
        @grpc_endpoint_template_path,
        service_names: services
      )

    Logger.debug("Endpoint defined: #{mod}")
    mod_compiled = Util.compile(mod)
    Logger.debug("Endpoint compiled: #{inspect(mod_compiled)}")

    {:ok, entities}
  end

  defp start_proxy(args) do
    Logger.info("Starting gRPC Server...")
    Application.put_env(:grpc, :start_server, true, persistent: true)

    spec =
      {GRPC.Server.Supervisor,
       {Massa.Server.Grpc.ProxyEndpoint, Application.get_env(:massa_proxy, :proxy_port)}}

    DynamicSupervisor.start_child(MassaProxy.LocalSupervisor, spec)
  end
end
