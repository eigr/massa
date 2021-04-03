defmodule MassaProxy.Supervisor do
  @moduledoc false
  use Supervisor
  require Logger

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    children =
      [
        http_server(),
        cluster_supervisor(),
        {Task.Supervisor, name: MassaProxy.TaskSupervisor},
        {DynamicSupervisor, [name: MassaProxy.LocalSupervisor, strategy: :one_for_one]},
        {Horde.Registry, [name: MassaProxy.GlobalRegistry, keys: :unique]},
        {Horde.DynamicSupervisor, [name: MassaProxy.GlobalSupervisor, strategy: :one_for_one]},
        %{
          id: MassaProxy.Cluster.HordeConnector,
          restart: :transient,
          start: {
            Task,
            :start_link,
            [
              fn ->
                MassaProxy.Cluster.HordeConnector.connect()
                MassaProxy.Cluster.HordeConnector.start_children()

                Node.list()
                |> Enum.each(fn node ->
                  :ok = MassaProxy.Cluster.StateHandoff.join(node)
                end)
              end
            ]
          }
        },
        MassaProxy.Cluster.NodeListener,
        Discovery.Worker
      ]
      |> Enum.reject(&is_nil/1)

    Supervisor.init(children, strategy: :one_for_one)
  end

  # Run libcluster supervisor if configuration is set.
  defp cluster_supervisor() do
    cluster_strategy = Application.get_env(:massa_proxy, :proxy_cluster_strategy)

    topologies =
      case cluster_strategy do
        "kubernetes-dns" -> get_dns_strategy()
        _ -> Application.get_env(:libcluster, :topologies)
      end

    if topologies && Code.ensure_compiled(Cluster.Supervisor) do
      Logger.info(
        "Cluster Strategy #{Application.get_env(:massa_proxy, :proxy_cluster_strategy)}"
      )

      Logger.debug("Cluster topology #{inspect(topologies)}")
      {Cluster.Supervisor, [topologies, [name: MassaProxy.ClusterSupervisor]]}
    end
  end

  defp http_server() do
    port = get_http_port()
    Logger.info("Starting HTTP Server on port #{port}")

    Plug.Cowboy.child_spec(
      scheme: :http,
      plug: Http.Endpoint,
      options: [port: get_http_port()]
    )
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
