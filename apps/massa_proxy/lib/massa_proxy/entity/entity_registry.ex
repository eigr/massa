defmodule MassaProxy.Entity.EntityRegistry do
  @moduledoc false
  use GenServer
  require Logger

  alias Phoenix.PubSub

  @topic "entities"

  def child_spec(state \\ %{}) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [state]},
      shutdown: 10_000,
      restart: :transient
    }
  end

  @impl true
  def init(state) do
    Process.flag(:trap_exit, true)
    Logger.debug("Initializing Entity Registry with state #{inspect(state)}")
    PubSub.subscribe(:entity_channel, @topic)
    {:ok, state}
  end

  @impl true
  def handle_cast({:register, new_entities}, state) do
    # convert initial state to map if empty list
    actual_state =
      case state do
        [] -> %{}
        _ -> state
      end

    # Accumulate new entities for the node key
    new_state =
      Enum.reduce(new_entities, actual_state, fn entity, acc ->
        acc_entity = Map.get(acc, entity.node)

        entities =
          case acc_entity do
            nil -> [entity]
            _ -> [entity] ++ Map.get(acc, entity.node)
          end

        Map.put(acc, entity.node, entities)
      end)

    # send new entities of this node to all connected nodes
    node = Node.self()

    PubSub.broadcast(
      :entity_channel,
      @topic,
      {:join, %{node => new_entities}}
    )

    {:noreply, new_state}
  end

  @impl true
  def handle_call({:get, entity_type}, _from, state) do
    nodes =
      state
      |> Enum.reduce([], fn {key, value}, acc ->
        for entity <- value do
          if entity.entity_type == entity_type do
            [key] ++ acc
          end
        end
      end)
      |> List.flatten()

    if Enum.all?(nodes, &is_nil/1) do
      {:reply, [], state}
    else
      {:reply, nodes, state}
    end
  end

  @impl true
  def handle_info({:join, message}, state) do
    self = Node.self()

    if Map.has_key?(message, self) do
      Logger.debug("Ignoring Entity join of Node: [#{inspect(Node.self())}]")
      {:noreply, state}
    else
      Logger.debug("New Entity join. Entity: #{inspect(message)}")
      {:noreply, include_entities(state, message)}
    end
  end

  @impl true
  def handle_info({:leave, %{node: node} = message}, state) do
    Logger.debug("Rebalancing after Entity leaves the cluster")
    {:noreply, state}
  end

  @impl true
  def terminate(_reason, _state) do
    node = Node.self()

    PubSub.broadcast(
      :entity_channel,
      @topic,
      {:leave, %{node => node}}
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
  def lookup(entity_type) do
    GenServer.call(__MODULE__, {:get, entity_type})
  end

  defp include_entities(state, message), do: Map.merge(state, message)
end
