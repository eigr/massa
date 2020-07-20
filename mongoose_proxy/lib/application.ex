defmodule MongooseProxyApplication do
  use Application
  import Supervisor.Spec

  @impl true
  def start(_type, _args) do
    children = [
      worker(Dicovery.ManagerServer, [])
    ]

    opts = [strategy: :one_for_one, name: Dicovery.ManagerServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
