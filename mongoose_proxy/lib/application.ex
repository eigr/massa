defmodule MongooseProxyApplication do
  use Application
  import Supervisor.Spec

  @impl true
  def start(_type, _args) do
    children = [
      cluster_supervisor,
      worker(EventSourced.Router, []),
      supervisor(Discovery.WorkerSupervisor, [])
    ]

    opts = [strategy: :one_for_one, name: Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp cluster_supervisor() do
    topologies = Application.get_env(:libcluster, :topologies)

    if topologies && Code.ensure_compiled?(Cluster.Supervisor) do
      {Cluster.Supervisor, [topologies, [name: Supervisor.ClusterSupervisor]]}
    end
  end
end
