defmodule MassaProxy.Entity.EntityRegistry do
  @moduledoc false
  use GenServer
  require Logger

  alias Phoenix.PubSub

  @topic "entities"

  def child_spec(state) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [state]},
      shutdown: 10_000,
      restart: :transient
    }
  end

  def init(state) do
    Logger.debug("Initializing Entity Registry...")
    Process.flag(:trap_exit, true)
    PubSub.subscribe(:entity_channel, @topic)
    {:ok, state}
  end

  def handle_cast({:register, new_entities}, state) do
    node = Node.self()

    PubSub.broadcast(
      :entity_channel,
      @topic,
      {:join, %{node => new_entities}}
    )

    {:noreply, state ++ new_entities}
  end

  def handle_call({:get}, _from, state = {_, entities}) do
    {:reply, entities, state}
  end

  def handle_info({:join, message}, state) do
    self = Node.self()

    if !Map.has_key?(message, self) do
      Logger.debug("New Entity join. Entity: #{inspect(message)}")
      {:noreply, include_entity(state, message)}
    else
      Logger.debug("Ignoring Entity join of Node: [#{inspect(Node.self())}]")
      {:noreply, state}
    end
  end

  def handle_info({:leave, message}, state) do
    {:noreply, message}
  end

  def terminate(_reason, state) do
    node = Node.self()

    PubSub.broadcast(
      :entity_channel,
      @topic,
      {:leave, %{node => state}}
    )

    :ok
  end

  def start_link(_args) do
    # note the change here in providing a name: instead of [] as the 3rd param
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  # register entities to the service
  def register(_args, entities) do
    GenServer.cast(__MODULE__, {:register, entities})
  end

  # fetch current entities of the service
  def lookup(_args) do
    GenServer.call(__MODULE__, {:get})
  end

  defp include_entity(state, message) do
    new_state =
      message
      |> Enum.map(fn {key, value} -> {key, value} end)
      |> Enum.into(state)

    new_state
  end
end
