defmodule MassaProxy.Children do
  @moduledoc false
  use Supervisor

  alias Runtime
  alias Runtime.{MiddlewareDefinition, State}

  require Logger

  def start_link(config) do
    Supervisor.start_link(__MODULE__, config, name: __MODULE__)
  end

  @impl true
  def init(config) do
    children = mount_supervisor_tree(config)

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp mount_supervisor_tree(config) do
    [
      http_server(config),
      {Registry, [name: MassaProxy.LocalRegistry, keys: :unique]},
      {DynamicSupervisor, [name: MassaProxy.LocalSupervisor, strategy: :one_for_one]},
      {DynamicSupervisor,
       [name: MassaProxy.Runtime.MiddlewareSupervisor, strategy: :one_for_one]},
      {MassaProxy.Infra.Cache.Distributed, []},
      # {Runtime, %State{middlewares: [%MiddlewareDefinition{}]}}
      local_node(),
      %{
        id: CachedServers,
        start: {MassaProxy.Infra.Cache, :start_link, [[cache_name: :cached_servers]]}
      },
      %{
        id: ReflectionCache,
        start: {MassaProxy.Infra.Cache, :start_link, [[cache_name: :reflection_cache]]}
      }
    ]
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
