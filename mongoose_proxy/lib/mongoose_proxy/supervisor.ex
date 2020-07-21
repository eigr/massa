defmodule MongooseProxy.Supervisor do
  @moduledoc false
  use Supervisor
  require Logger

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    children =
      [
        cluster_supervisor(),
        {Horde.Registry, [name: MongooseProxy.GlobalRegistry, keys: :unique]},
        {Horde.DynamicSupervisor, [name: MongooseProxy.GlobalSupervisor, strategy: :one_for_one]},
        %{
          id: MongooseProxy.HordeConnector,
          restart: :transient,
          start: {
            Task,
            :start_link,
            [
              fn ->
                MongooseProxy.HordeConnector.connect()
                MongooseProxy.HordeConnector.start_children()
              end
            ]
          }
        }
      ]
      |> Enum.reject(&is_nil/1)

    Supervisor.init(children, strategy: :one_for_one)
  end

  # Run libcluster supervisor if configuration is set.
  defp cluster_supervisor() do
    topologies = Application.get_env(:libcluster, :topologies)

    if topologies && Code.ensure_compiled?(Cluster.Supervisor) do
      {Cluster.Supervisor, [topologies, [name: MongooseProxy.ClusterSupervisor]]}
    end
  end
end
