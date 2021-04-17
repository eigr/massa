defmodule MassaProxy.Server.GrpcServer do
  @moduledoc false
  require Logger

  alias MassaProxy.{Util, Infra.Cache}

  def start(descriptors, entities) do
    case Cache.get(:servers, :grpc) do
      nil -> start_grpc(descriptors, entities)
      _ -> Logger.debug("gRPC Server already started")
    end
  end

  defp start_grpc(descriptors, entities) do
    {u_secs, _} =
      :timer.tc(fn ->
        with {:ok, descriptors} <- descriptors |> compile(),
             {:ok, _} <- generate_services(entities),
             {:ok, _} <- generate_endpoints(entities) do
          start_proxy(descriptors, entities)
        else
          _ -> Logger.error("Error during gRPC Server initialization")
        end

        :ok
      end)

    Logger.info("Started gRPC Server in #{u_secs / 1_000_000}ms")
  end

  defp compile(descriptors) do
    files =
      descriptors
      |> MassaProxy.Reflection.prepare()

    for file <- files do
      result = Util.compile(file)
      Logger.debug("Compiled module: #{inspect(result)}")
    end

    {:ok, descriptors}
  end

  defp generate_services(entities) do
    root_template_path =
      Application.get_env(
        :massa_proxy,
        :proxy_root_template_path,
        :code.priv_dir(:massa_proxy)
      )

    grpc_template_path =
      Path.expand(
        "./templates/grpc_service.ex.eex",
        root_template_path
      )

    for entity <- entities do
      name = Enum.join([Util.normalize_service_name(entity.service_name), "Service"], ".")
      services = Enum.at(entity.services, 0) |> Enum.at(0)

      methods =
        services.methods
        |> Flow.from_enumerable()
        |> Flow.map(&Util.normalize_mehod_name(&1.name))
        |> Enum.to_list()

      Logger.info("Generating Service #{name} with Methods: #{inspect(methods)}")

      original_methods = get_method_names(services)
      input_types = get_input_type(services)
      output_types = get_output_type(services)
      request_types = get_request_type(services)

      mod =
        Util.get_module(
          grpc_template_path,
          mod_name: name,
          name: name,
          methods: methods,
          original_methods: original_methods,
          handler: "MassaProxy.Server.Dispatcher",
          entity_type: entity.entity_type,
          persistence_id: entity.persistence_id,
          service_name: entity.service_name,
          input_types: input_types,
          output_types: output_types,
          request_types: request_types
        )

      Logger.debug("Service defined: #{mod}")
      mod_compiled = Util.compile(mod)
      Logger.debug("Service compiled: #{inspect(mod_compiled)}")
    end

    {:ok, entities}
  end

  defp generate_endpoints(entities) do
    root_template_path =
      Application.get_env(
        :massa_proxy,
        :proxy_root_template_path,
        :code.priv_dir(:massa_proxy)
      )

    grpc_endpoint_template_path =
      Path.expand(
        "./templates/grpc_endpoint.ex.eex",
        root_template_path
      )

    services =
      entities
      |> Flow.from_enumerable()
      |> Flow.map(
        &Enum.join([Util.normalize_service_name(&1.service_name), "Service.ProxyService"], ".")
      )
      |> Enum.to_list()

    mod =
      Util.get_module(
        grpc_endpoint_template_path,
        service_names: services
      )

    Logger.debug("Endpoint defined: #{mod}")
    mod_compiled = Util.compile(mod)
    Logger.debug("Endpoint compiled: #{inspect(mod_compiled)}")

    {:ok, entities}
  end

  defp start_proxy(descriptors, entities) do
    Logger.info("Starting gRPC Server...")
    Application.put_env(:grpc, :start_server, true, persistent: true)

    server_spec =
      {GRPC.Server.Supervisor,
       {Massa.Server.Grpc.ProxyEndpoint, Application.get_env(:massa_proxy, :proxy_port)}}

    reflection_spec = MassaProxy.Reflection.Server.child_spec(descriptors)

    with {:ok, _} <- DynamicSupervisor.start_child(MassaProxy.LocalSupervisor, server_spec),
         {:ok, _} <- DynamicSupervisor.start_child(MassaProxy.LocalSupervisor, reflection_spec) do
      Cache.put(:servers, :grpc, true)
    end
  end

  defp get_method_names(services),
    do:
      Enum.reduce(services.methods, %{}, fn method, acc ->
        Map.put(
          acc,
          Util.normalize_mehod_name(method.name),
          method.name
        )
      end)

  defp get_input_type(services),
    do:
      Enum.reduce(services.methods, %{}, fn method, acc ->
        Map.put(
          acc,
          Util.normalize_mehod_name(method.name),
          String.replace_leading(Util.normalize_service_name(method.input_type), ".", "")
        )
      end)

  defp get_output_type(services),
    do:
      Enum.reduce(services.methods, %{}, fn method, acc ->
        Map.put(
          acc,
          Util.normalize_mehod_name(method.name),
          String.replace_leading(Util.normalize_service_name(method.output_type), ".", "")
        )
      end)

  defp get_request_type(services),
    do:
      Enum.reduce(services.methods, %{}, fn method, acc ->
        Map.put(acc, Util.normalize_mehod_name(method.name), get_type(method))
      end)

  defp get_type(method) do
    type =
      cond do
        method.unary == true -> "unary"
        method.streamed == true -> "streamed"
        method.stream_in == true -> "stream_in"
        method.stream_out == true -> "stream_out"
      end

    type
  end
end
