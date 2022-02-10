defmodule MassaProxy.Runtime.MiddlewareSupervisor do
  @moduledoc """

  """
  use DynamicSupervisor

  @impl true
  def init(_opts), do: DynamicSupervisor.init(strategy: :one_for_one)

  @doc false
  def start_link(_opts),
    do: DynamicSupervisor.start_link(__MODULE__, [shutdown: 120_000], name: __MODULE__)

  def start_middleware(state) do
    child_spec = %{
      id: MassaProxy.Runtime.Middleware,
      start: {MassaProxy.Runtime.Middleware, :start_link, [state]},
      restart: :transient
    }

    case DynamicSupervisor.start_child(__MODULE__, child_spec) do
      {:error, {:already_started, pid}} -> {:ok, pid}
      {:ok, pid} -> {:ok, pid}
    end
  end
end
