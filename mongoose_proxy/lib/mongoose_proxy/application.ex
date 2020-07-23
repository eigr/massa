defmodule MongooseProxy.Application do
  use Application

  @impl true
  def start(_type, _args) do
    ExRay.Store.create()
    Metrics.Setup.setup()
    MongooseProxy.Supervisor.start_link([])
  end
end
