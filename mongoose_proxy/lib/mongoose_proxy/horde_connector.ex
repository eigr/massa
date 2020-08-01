defmodule MongooseProxy.HordeConnector do
  @moduledoc false
  require Logger

  def connect() do
    Logger.info("Starting Proxy Cluster...")

    set_members(MongooseProxy.GlobalRegistry)
    set_members(MongooseProxy.GlobalSupervisor)
  end

  def start_children() do
    Logger.debug("Starting Supervisors...")

    #Horde.DynamicSupervisor.start_child(
    #  MongooseProxy.Supervisor,
    #  MongooseProxy.EntityRegistry
    #)

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
