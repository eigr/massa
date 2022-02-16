defmodule MassaProxy.Util do
  @moduledoc false
  require Logger

  alias Injectx.Context

  def setup() do
    Logger.info(
      "Available BEAM Schedulers: #{System.schedulers()}. Online BEAM Schedulers: #{System.schedulers_online()}"
    )

    :ets.new(:servers, [:set, :public, :named_table])
    ExRay.Store.create()
    Metrics.Setup.setup()

    config = MassaProxy.Infra.Config.Vapor.load()

    config_bindings = %Context.Binding{
      behavior: MassaProxy.Infra.Config,
      definitions: [
        %Context.BindingDefinition{module: MassaProxy.Infra.Config.Vapor, default: true}
      ]
    }

    runtime_bindings =
      case config.proxy_runtime_type do
        "GRPC" ->
          %Context.Binding{
            behavior: MassaProxy.Runtime,
            definitions: [
              %Context.BindingDefinition{module: MassaProxy.Runtime.Grpc, default: true},
              %Context.BindingDefinition{module: MassaProxy.Runtime.Wasm, default: false}
            ]
          }

        "WASM" ->
          %Context.Binding{
            behavior: MassaProxy.Runtime,
            definitions: [
              %Context.BindingDefinition{module: MassaProxy.Runtime.Grpc, default: false},
              %Context.BindingDefinition{module: MassaProxy.Runtime.Wasm, default: true}
            ]
          }
      end

    context = %Context{
      bindings: [
        config_bindings,
        runtime_bindings
      ]
    }

    Context.from(context)
    Node.set_cookie(String.to_atom(config.proxy_cookie))

    config
  end

  def cluster_supervisor(config) do
    cluster_strategy = config.proxy_cluster_strategy

    topologies =
      case cluster_strategy do
        "gossip" ->
          get_gossip_strategy()

        "kubernetes-dns" ->
          get_dns_strategy(config)

        _ ->
          Logger.warn("Invalid Topology")
      end

    if topologies && Code.ensure_compiled(Cluster.Supervisor) do
      Logger.info("Cluster Strategy #{cluster_strategy}")

      Logger.debug("Cluster topology #{inspect(topologies)}")
      {Cluster.Supervisor, [topologies, [name: MassaProxy.ClusterSupervisor]]}
    end
  end

  def contains_key?(field_descriptor) do
    Logger.debug("FieldOptions: #{inspect(field_descriptor)}")

    entity_key_ext =
      Google.Protobuf.FieldOptions.get_extension(
        field_descriptor.options,
        Cloudstate.PbExtension,
        :entity_key
      )

    Logger.debug("Entity key extension: #{inspect(entity_key_ext)}")
    entity_key_ext
  end

  def get_http_rule(method_descriptor) do
    Logger.debug("MethodOptions HTTP Rules: #{inspect(method_descriptor)}")

    Google.Protobuf.MethodOptions.get_extension(
      method_descriptor.options,
      Google.Api.PbExtension,
      :http
    )
  end

  def get_eventing_rule(method_descriptor) do
    Logger.debug("MethodOptions Eventing Rules: #{inspect(method_descriptor)}")

    evt_ext =
      Google.Protobuf.MethodOptions.get_extension(
        method_descriptor.options,
        Cloudstate.PbExtension,
        :eventing
      )

    Logger.debug("Eventing extension: #{inspect(evt_ext)}")
    evt_ext
  end

  def get_type(method) do
    type =
      cond do
        method.unary == true -> "unary"
        method.streamed == true -> "streamed"
        method.stream_in == true -> "stream_in"
        method.stream_out == true -> "stream_out"
      end

    type
  end

  def get_type_url(type) when is_binary(type) do
    if String.contains?(type, "type.googleapis.com/") do
      type
    else
      raise "Invalid type: #{type}"
    end
  end

  def get_type_url(type) when is_atom(type) do
    parts =
      type
      |> to_string
      |> String.replace("Elixir.", "")
      |> String.split(".")

    package_name =
      with {_, list} <- parts |> List.pop_at(-1),
           do: list |> Stream.map(&String.downcase(&1)) |> Enum.join(".")

    type_name = parts |> List.last()
    "type.googleapis.com/#{package_name}.#{type_name}"
  end

  def compile(file) do
    Code.compile_string(file)
  rescue
    error in UndefinedFunctionError ->
      Logger.error("Error in Module definition. Make sure the service name is correct")
      raise error

    error ->
      Logger.error("Error during Service compilation phase #{inspect(error)}")
  end

  def normalize_service_name(name) do
    name
    |> String.split(".")
    |> Stream.map(&Macro.camelize(&1))
    |> Enum.join(".")
  end

  def normalize_method_name(name), do: Macro.underscore(name)

  def get_module(filename, bindings \\ []), do: EEx.eval_file(filename, bindings)

  def get_connection(),
    do:
      GRPC.Stub.connect(get_address(is_uds_enable?()),
        interceptors: [GRPC.Logger.Client],
        adapter_opts: %{http2_opts: %{keepalive: 10000}}
      )

  def get_uds_address(),
    do: Application.get_env(:massa_proxy, :user_function_sock_addr, "/var/run/cloudstate.sock")

  def is_uds_enable?(),
    do: Application.get_env(:massa_proxy, :user_function_uds_enable, false)

  defp get_function_host(),
    do: Application.get_env(:massa_proxy, :user_function_host, "127.0.0.1")

  def get_function_port(), do: Application.get_env(:massa_proxy, :user_function_port, 8080)

  def get_address(false), do: "#{get_function_host()}:#{get_function_port()}"

  def get_address(true), do: "#{get_uds_address()}"

  defp get_gossip_strategy(),
    do: [
      proxy: [
        strategy: Cluster.Strategy.Gossip
      ]
    ]

  defp get_dns_strategy(config),
    do: [
      proxy: [
        strategy: Elixir.Cluster.Strategy.Kubernetes.DNS,
        config: [
          service: config.proxy_headless_service,
          application_name: config.proxy_app_name,
          polling_interval: config.proxy_cluster_poling_interval
        ]
      ]
    ]
end
