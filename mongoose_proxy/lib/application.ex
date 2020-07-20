defmodule MongooseProxyApplication do
  use Application
  import Supervisor.Spec

  @impl true
  def start(_type, _args) do
    children = [
      worker(EventSourced.Router, []),
      supervisor(Discovery.WorkerSupervisor, [])
    ]

    opts = [strategy: :one_for_one, name: Supervisor]
    Supervisor.start_link(children, opts)
  end
end
