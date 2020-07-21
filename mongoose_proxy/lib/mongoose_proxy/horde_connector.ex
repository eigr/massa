defmodule MongooseProxy.HordeConnector do
  @moduledoc false
  require Logger

  def connect() do
    Logger.info("Starting Proxy Cluster...")

    Node.list()
    |> Enum.each(fn node ->
      Logger.debug(fn ->
        "[mongoose proxy on #{inspect(Node.self())}]: Connecting Horde to #{inspect(node)}"
      end)

      #Horde.Cluster.join_hordes(
      #  MongooseProxy.GlobalRegistry,
      #  {MongooseProxy.GlobalRegistry, node}
      #)

      #Horde.Cluster.join_hordes(
      #  MongooseProxy.GlobalSupervisor,
      #  {MongooseProxy.GlobalSupervisor, node}
      #)
    end)
  end

  def start_children() do
    Logger.debug("Starting Supervisors...")

    Horde.DynamicSupervisor.start_child(
      MongooseProxy.Supervisor,
      Discovery.Worker
    )

    Horde.DynamicSupervisor.start_child(MongooseProxy.Supervisor, EventSourced.Router)
  end
end
