defmodule MassaProxy do
  @moduledoc false
  use Application
  require Logger
  alias Injectx.Context
  alias Vapor.Provider.{Env, Dotenv}

  @before_init [
    {Task.Supervisor, name: MassaProxy.TaskSupervisor},
    {Registry, [name: MassaProxy.LocalRegistry, keys: :unique]},
    {MassaProxy.Infra.Cache.Distributed, []},
    {DynamicSupervisor, [name: MassaProxy.LocalSupervisor, strategy: :one_for_one]}
  ]

  @horde [
    MassaProxy.GlobalRegistry,
    MassaProxy.GlobalSupervisor
  ]

  @after_init [
    {MassaProxy.Entity.EntityRegistry.Supervisor, [%{}]},
    %{
      id: CachedServers,
      start: {MassaProxy.Infra.Cache, :start_link, [[cache_name: :cached_servers]]}
    },
    %{
      id: ReflectionCache,
      start: {MassaProxy.Infra.Cache, :start_link, [[cache_name: :reflection_cache]]}
    }
  ]

  @impl true
  def start(_type, _args) do
    config = setup()

    children =
      ([
         http_server(),
         cluster_supervisor()
       ] ++
         @before_init ++
         @horde ++
         horde_connector() ++
         @after_init)
      |> Stream.reject(&is_nil/1)
      |> Enum.to_list()

    opts = [strategy: :one_for_one, name: MassaProxy.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp setup() do
    Logger.info(
      "Available BEAM Schedulers: #{System.schedulers()}. Online BEAM Schedulers: #{
        System.schedulers_online()
      }"
    )

    :ets.new(:servers, [:set, :public, :named_table])
    ExRay.Store.create()
    Metrics.Setup.setup()

    config = load_system_env()
    Node.set_cookie(get_cookie())

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
        runtime_bindings
      ]
    }

    Context.from(context)

    config
  end

  defp load_system_env() do
    priv_root_path = :code.priv_dir(:massa_proxy)
    cert_path = Path.expand("./tls/server1.pem", :code.priv_dir(:massa_proxy))
    key_path = Path.expand("./tls/server1.key", :code.priv_dir(:massa_proxy))

    providers = [
      %Dotenv{},
      %Env{
        bindings: [
          {:proxy_runtime_type, "PROXY_RUNTIME_TYPE", default: "GRPC", required: false},
          {:proxy_cookie, "NODE_COOKIE", default: "massa_proxy", required: false},
          {:proxy_root_template_path, "PROXY_ROOT_TEMPLATE_PATH",
           default: priv_root_path, required: false},
          {:proxy_cluster_strategy, "PROXY_CLUSTER_STRATEGY", default: "gossip", required: false},
          {:proxy_headless_service, "PROXY_HEADLESS_SERVICE",
           default: "proxy-headless-svc", required: false},
          {:proxy_app_name, "PROXY_APP_NAME", default: "massa-proxy", required: false},
          {:proxy_cluster_poling_interval, "PROXY_CLUSTER_POLLING",
           default: 3_000, map: &String.to_integer/1, required: false},
          {:proxy_port, "PROXY_PORT", default: 9000, map: &String.to_integer/1, required: false},
          {:proxy_http_port, "PROXY_HTTP_PORT",
           default: 9001, map: &String.to_integer/1, required: false},
          {:user_function_host, "USER_FUNCTION_HOST", default: "0.0.0.0", required: false},
          {:user_function_port, "USER_FUNCTION_PORT",
           default: 8080, map: &String.to_integer/1, required: false},
          {:user_function_uds_enable, "PROXY_UDS_MODE", default: false, required: false},
          {:user_function_sock_addr, "PROXY_UDS_ADDRESS",
           default: "/var/run/cloudstate.sock", required: false},
          {:heartbeat_interval, "PROXY_HEARTBEAT_INTERVAL",
           default: 60_000, map: &String.to_integer/1, required: false},
          {:tls, "PROXY_TLS", default: false, required: false},
          {:tls_cert_path, "PROXY_TLS_CERT_PATH", default: cert_path, required: false},
          {:tls_key_path, "PROXY_TLS_KEY_PATH", default: key_path, required: false}
        ]
      }
    ]

    config = Vapor.load!(providers)

    set_vars(config)
    config
  end

  defp set_vars(config),
    do:
      Enum.each(config, fn k, v -> Application.put_env(:massa_proxy, k, v, persistent: true) end)

  defp get_cookie(), do: String.to_atom(Application.get_env(:massa_proxy, :proxy_cookie))

  defp horde_connector() do
    [
      %{
        id: MassaProxy.Cluster.HordeConnector,
        restart: :transient,
        start: {
          Task,
          :start_link,
          [
            fn ->
              Horde.DynamicSupervisor.start_child(
                MassaProxy.Supervisor,
                {MassaProxy.Protocol.Discovery.Worker, []}
              )

              Horde.DynamicSupervisor.start_child(
                MassaProxy.Supervisor,
                {MassaProxy.Cluster.StateHandoff, []}
              )

              Node.list()
              |> Stream.each(fn node ->
                :ok = MassaProxy.Cluster.StateHandoff.join(node)
              end)
              |> Stream.run()
            end
          ]
        }
      }
    ]
  end

  defp cluster_supervisor() do
    cluster_strategy = Application.get_env(:massa_proxy, :proxy_cluster_strategy)

    topologies =
      case cluster_strategy do
        "kubernetes-dns" -> get_dns_strategy()
        _ -> Application.get_env(:libcluster, :topologies)
      end

    if topologies && Code.ensure_compiled(Cluster.Supervisor) do
      Logger.info("Cluster Strategy #{cluster_strategy}")

      Logger.debug("Cluster topology #{inspect(topologies)}")
      {Cluster.Supervisor, [topologies, [name: MassaProxy.ClusterSupervisor]]}
    end
  end

  defp http_server() do
    port = get_http_port()

    plug_spec =
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Http.Endpoint,
        options: [port: port]
      )

    Logger.info("HTTP Server started on port #{port}")
    plug_spec
  end

  defp get_http_port(), do: Application.get_env(:massa_proxy, :proxy_http_port, 9001)

  defp get_dns_strategy() do
    topologies = [
      proxy: [
        strategy: Elixir.Cluster.Strategy.Kubernetes.DNS,
        config: [
          service: Application.get_env(:massa_proxy, :proxy_headless_service),
          application_name: Application.get_env(:massa_proxy, :proxy_app_name),
          polling_interval: Application.get_env(:massa_proxy, :proxy_cluster_poling_interval)
        ]
      ]
    ]

    topologies
  end
end
