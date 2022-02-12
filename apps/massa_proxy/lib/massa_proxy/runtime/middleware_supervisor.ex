defmodule MassaProxy.Runtime.MiddlewareSupervisor do
  @moduledoc """
  Supervisor for the middleware stack.
  """
  use DynamicSupervisor

  alias MassaProxy.Runtime.Middleware

  @impl true
  def init(_opts), do: DynamicSupervisor.init(strategy: :one_for_one)

  @doc false
  def start_link(_opts),
    do: DynamicSupervisor.start_link(__MODULE__, [shutdown: 120_000], name: __MODULE__)

  def start_middleware(%{entity_type: entity_type} = state) do
    process_name = get_name(entity_type)

    child_spec = %{
      id: process_name,
      start: {Middleware, :start_link, [Map.put(state, :name, process_name)]},
      restart: :transient
    }

    case DynamicSupervisor.start_child(__MODULE__, child_spec) do
      {:error, {:already_started, pid}} -> {:ok, pid}
      {:ok, pid} -> {:ok, pid}
    end
  end

  defp get_name(entity_type) do
    mod =
      entity_type
      |> String.split(".")
      |> Enum.at(-1)

    Module.concat(Middleware, mod)
  end
end
