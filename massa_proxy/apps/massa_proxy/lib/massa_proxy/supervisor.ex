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
        MassaProxy.Cluster.NodeListener
      ]
      |> Enum.reject(&is_nil/1)

    Supervisor.init(children, strategy: :one_for_one)
  end

  # Run libcluster supervisor if configuration is set.
  defp cluster_supervisor() do
    topologies = Application.get_env(:libcluster, :topologies)

    if topologies && Code.ensure_compiled(Cluster.Supervisor) do
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
end
