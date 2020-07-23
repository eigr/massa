defmodule MongooseProxy.EntityRegistry do
  @moduledoc false
  use GenServer
  require Logger

  def child_spec(opts) do
    horde = :"h#{-:erlang.monotonic_time()}"
    name = Keyword.get(opts, :name, horde)

    %{
      id: "#{__MODULE__}_#{name}",
      start: {__MODULE__, :start_link, [name]},
      shutdown: 10_000,
      restart: :transient
    }
  end

  def init(_opts) do
    Logger.info("[MongooseProxy on #{inspect(Node.self())}][EntityRegistry]: Initializing...")

    {:ok, nil}
  end

  def start_link(name) do
    case GenServer.start_link(__MODULE__, [], name: via_tuple(name)) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        Logger.info("already started at #{name}:#{inspect(pid)}, returning :ignore")
        :ignore
    end
  end

  defp via_tuple(name) do
    {:via, Horde.Registry, {MongooseProxy.GlobalRegistry, name}}
  end
end
