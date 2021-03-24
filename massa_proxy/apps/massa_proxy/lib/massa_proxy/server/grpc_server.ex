defmodule MassaProxy.Server.GrpcServer do
  @moduledoc false
  require Logger

  @grpc_template_path Path.expand("./templates/grpc_service.ex.eex", :code.priv_dir(:massa_proxy))
  @grpc_endpoint_template_path Path.expand(
                                 "./templates/grpc_endpoint.ex.eex",
                                 :code.priv_dir(:massa_proxy)
                               )

  def start(descriptors, entities), do: start_grpc(descriptors, entities)

  defp start_grpc(descriptors, entities) do
    {uSecs, result} =
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

    Logger.info("Started gRPC Server in #{uSecs/1_000_000}ms")
  end

  defp compile(descriptors) do
    files =
      descriptors
      |> MassaProxy.Reflection.compile()

    for file <- files do
      result = Code.eval_string(file)
      Logger.debug("Compiled module: #{inspect(result)}")
    end

    {:ok, descriptors}
  end

  defp generate_services(entities) do
    for entity <- entities do
      name = Enum.join([normalize_service_name(entity.service_name), "Service"], ".")
      services = Enum.at(entity.services, 0) |> Enum.at(0)

      methods =
        services.methods
        |> Flow.from_enumerable()
        |> Flow.map(&normalize_mehod_name(&1.name))
        |> Enum.to_list()

      Logger.info("Generating Service #{name} with Methods: #{inspect(methods)}")

      mod =
        EEx.eval_file(
          @grpc_template_path,
          mod_name: name,
          name: name,
          methods: methods,
          handler: "MassaProxy.Server.Dispatcher",
          entity_type: entity.entity_type,
          persistence_id: entity.persistence_id
        )

      Logger.debug("Service defined: #{mod}")
      mod_compiled = Code.eval_string(mod)
      Logger.debug("Service compiled: #{inspect(mod_compiled)}")
    end

    {:ok, entities}
  end

  defp generate_endpoints(entities) do
    services =
      entities
      |> Flow.from_enumerable()
      |> Flow.map(
        &Enum.join([normalize_service_name(&1.service_name), "Service.ProxyService"], ".")
      )
      |> Enum.to_list()

    mod =
      EEx.eval_file(
        @grpc_endpoint_template_path,
        service_names: services
      )

    Logger.debug("Endpoint defined: #{mod}")
    mod_compiled = Code.eval_string(mod)
    Logger.debug("Endpoint compiled: #{inspect(mod_compiled)}")

    {:ok, entities}
  end

  defp start_proxy(args) do
    Logger.info("Starting gRPC Server...")
    Application.put_env(:grpc, :start_server, true, persistent: true)
    spec = {GRPC.Server.Supervisor, {Massa.Server.Grpc.ProxyEndpoint, 9980}}
    DynamicSupervisor.start_child(MassaProxy.LocalSupervisor, spec)
  end

  defp normalize_service_name(name) do
    name
    |> String.split(".")
    |> Enum.map(&Macro.camelize(&1))
    |> Enum.join(".")
  end

  defp normalize_mehod_name(name), do: Macro.underscore(name)
end
