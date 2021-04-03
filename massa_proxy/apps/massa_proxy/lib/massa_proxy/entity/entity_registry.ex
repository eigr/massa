defmodule MassaProxy.Entity.EntityRegistry do
  @moduledoc false
  use GenServer
  require Logger

  def child_spec(service) do
    %{
      id: service,
      start: {__MODULE__, :start_link, [service]},
      shutdown: 10_000,
      restart: :transient
    }
  end

  def start_link(service) do
    Logger.debug("Starting Registry for #{service}")
    # note the change here in providing a name: instead of [] as the 3rd param
    GenServer.start_link(__MODULE__, service, name: via_tuple(service))
  end

  def init(service) do
    Logger.debug("[MassaProxy on #{inspect(Node.self())}][EntityRegistry]: Initializing...")
    Process.flag(:trap_exit, true)
    entities = MassaProxy.Cluster.StateHandoff.pickup(service)
    {:ok, {service, entities}}
  end

  # register entities to the service
  def register(service, entities) do
    GenServer.cast(via_tuple(service), {:register, entities})
  end

  # fetch current entities of the service
  def lookup(service) do
    GenServer.call(via_tuple(service), {:get})
  end

  def handle_cast({:register, new_entities}, {service, entities}) do
    {:noreply, {service, entities ++ new_entities}}
  end

  def handle_call({:get}, _from, state = {_, entities}) do
    {:reply, entities, state}
  end

  def terminate(reason, {service, entities}) do
    MassaProxy.Cluster.StateHandoff.handoff(service, entities)
    :ok
  end

  defp via_tuple(service) do
    {:via, Horde.Registry, {MassaProxy.GlobalRegistry, service}}
  end
end
