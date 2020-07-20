defmodule Discovery.WorkerSupervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok)
  end

  @impl true
  def init(:ok) do
    children = [
      worker(Discovery.Worker, [])
    ]

    opts = [
      max_restarts: 1000,
      name: __MODULE__,
      strategy: :one_for_one
    ]

    Supervisor.init(children, opts)
  end
end
