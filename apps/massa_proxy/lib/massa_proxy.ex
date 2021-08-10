defmodule MassaProxy do
  @moduledoc false
  use Application
  require Logger
  alias Injectx.Context

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
         http_server(config),
         cluster_supervisor(config)
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
                {MassaProxy.Orchestrator, []}
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

  defp cluster_supervisor(config) do
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

  defp http_server(config) do
    port = get_http_port(config)

    plug_spec =
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Http.Endpoint,
        options: [port: port]
      )

    Logger.info("HTTP Server started on port #{port}")
    plug_spec
  end

  defp get_http_port(config), do: config.proxy_http_port

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
