defmodule MassaProxy.Entity.EntityRegistry do
  @moduledoc false
  use GenServer
  require Logger

  alias Phoenix.PubSub

  def child_spec(service) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [__MODULE__]},
      shutdown: 10_000,
      restart: :transient
    }
  end

  def init(service) do
    Logger.debug("Initializing EntityRegistry...")
    Process.flag(:trap_exit, true)
    PubSub.subscribe(:entity_channel, "entities")
    {:ok, {service, service}}
  end

  def handle_cast({:register, new_entities}, {service, entities}) do
    {:noreply, {service, entities ++ new_entities}}
  end

  def handle_call({:get}, _from, state = {_, entities}) do
    {:reply, entities, state}
  end

  def terminate(reason, {service, entities}) do
    :ok
  end

  def start_link(service) do
    # note the change here in providing a name: instead of [] as the 3rd param
    GenServer.start_link(__MODULE__, [], name: via_tuple(service))
  end

  # register entities to the service
  def register(service, entities) do
    # GenServer.cast(via_tuple(service), {:register, entities})
  end

  # fetch current entities of the service
  def lookup(service) do
    # GenServer.call(via_tuple(service), {:get})
  end

  defp via_tuple(service) do
    {:via, Registry, {MassaProxy.LocalRegistry, service}}
  end
end
