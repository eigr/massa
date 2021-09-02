defmodule MassaProxy do
  @moduledoc false
  use Application

  require Logger
  import MassaProxy.Util, only: [setup: 0, cluster_supervisor: 1]

  @impl true
  def start(_type, _args) do
    config = setup()

    children =
      [
        cluster_supervisor(config),
        {MassaProxy.Children, config}
      ]
      |> Stream.reject(&is_nil/1)
      |> Enum.to_list()

    opts = [strategy: :one_for_one, name: MassaProxy.RootSupervisor]
    Supervisor.start_link(children, opts)
  end
end
