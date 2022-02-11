defmodule MassaProxy.Children do
  @moduledoc false
  use Supervisor

  require Logger

  def start_link(config) do
    Supervisor.start_link(__MODULE__, config, name: __MODULE__)
  end

  @impl true
  def init(config) do
    children = [
      http_server(config),
      {Task.Supervisor, name: MassaProxy.TaskSupervisor},
      {Registry, [name: MassaProxy.LocalRegistry, keys: :unique]},
      {DynamicSupervisor, [name: MassaProxy.LocalSupervisor, strategy: :one_for_one]},
      {DynamicSupervisor,
       [name: MassaProxy.Runtime.MiddlewareSupervisor, strategy: :one_for_one]},
      {MassaProxy.Infra.Cache.Distributed, []},
      local_node(),
      {MassaProxy.Entity.EntityRegistry.Supervisor, [%{}]},
      %{
        id: CachedServers,
        start: {MassaProxy.Infra.Cache, :start_link, [[cache_name: :cached_servers]]}
      },
      %{
        id: ReflectionCache,
        start: {MassaProxy.Infra.Cache, :start_link, [[cache_name: :reflection_cache]]}
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp http_server(config) do
    port = get_http_port(config)

    plug_spec =
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Http.Endpoint,
        options: [port: port]
      )

    Logger.info("HTTP Server started on port #{port}")
    plug_spec
  end

  defp get_http_port(config), do: config.proxy_http_port

  defp local_node() do
    %{
      id: MassaProxy.Local.Orchestrator,
      restart: :transient,
      start: {
        Task,
        :start_link,
        [
          fn ->
            DynamicSupervisor.start_child(
              MassaProxy.LocalSupervisor,
              {MassaProxy.Orchestrator, []}
            )
          end
        ]
      }
    }
  end
end
