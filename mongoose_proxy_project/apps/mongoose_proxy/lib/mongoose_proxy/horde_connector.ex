defmodule MongooseProxy.HordeConnector do
  @moduledoc false
  require Logger

  def connect() do
    Logger.info("Starting Proxy Cluster...")

    set_members(MongooseProxy.GlobalRegistry)
    set_members(MongooseProxy.GlobalSupervisor)
  end

  def start_children() do
    # The order in which supervisors start matters, so be careful when you move here
    Logger.debug("Starting Supervisors...")

    Horde.DynamicSupervisor.start_child(
      MongooseProxy.Supervisor,
      {MongooseProxy.StateHandoff, []}
    )

    Horde.DynamicSupervisor.start_child(
      MongooseProxy.Supervisor,
      {MongooseProxy.EntityRegistry, "EventSourced"}
    )

    Horde.DynamicSupervisor.start_child(
      MongooseProxy.Supervisor,
      {MongooseProxy.EntityRegistry, "CRDT"}
    )

    Horde.DynamicSupervisor.start_child(
      MongooseProxy.Supervisor,
      {MongooseProxy.EntityRegistry, "Stateless"}
    )

    Horde.DynamicSupervisor.start_child(
      MongooseProxy.Supervisor,
      Discovery.Worker
    )

    Horde.DynamicSupervisor.start_child(MongooseProxy.Supervisor, EventSourced.Router)
  end

  defp set_members(name) do
    members =
      [Node.self() | Node.list()]
      |> Enum.map(fn node ->
        Logger.info(
          "[mongoose proxy on #{inspect(Node.self())}]: Connecting Horde to #{inspect(node)}"
        )

        {name, node}
      end)

    :ok = Horde.Cluster.set_members(name, members)
  end
end
