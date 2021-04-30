defmodule MassaProxy.GlobalSupervisor do
  @moduledoc false
  use Horde.DynamicSupervisor
  require Logger

  def child_spec() do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [%{}]}
    }
  end

  def start_link(_) do
    Horde.DynamicSupervisor.start_link(
      __MODULE__,
      [
        shutdown: 60_000,
        strategy: :one_for_one,
        members: :auto,
        process_redistribution: :passive
      ],
      name: __MODULE__
    )
  end

  def init(args) do
    [members: members()]
    |> Keyword.merge(args)
    |> Horde.DynamicSupervisor.init()
  end

  defp members() do
    [Node.self() | Node.list()]
    |> Enum.map(fn node ->
      Logger.debug("Supervisor Node #{inspect(Node.self())} joining with Node #{inspect(node)}")
      {__MODULE__, node}
    end)
  end
end
