defmodule Runtime do
  @moduledoc """
  `Runtime`.
  """
  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        {Task.Supervisor, name: ProxyRuntime.TaskSupervisor},
        {Runtime.Entity.EntityRegistry.Supervisor, [%{}]}
      ]
      |> Stream.reject(&is_nil/1)
      |> Enum.to_list()

    opts = [strategy: :one_for_one, name: ProxyRuntime.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
