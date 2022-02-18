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
