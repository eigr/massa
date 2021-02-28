defmodule MassaProxy.Application do
  use Application

  @impl true
  def start(_type, _args) do
    ExRay.Store.create()
    Metrics.Setup.setup()
    MassaProxy.Supervisor.start_link([])
  end
end
