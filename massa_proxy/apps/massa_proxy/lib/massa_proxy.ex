defmodule MassaProxy do
  @moduledoc false
  use Application
  require Logger
  alias Vapor.Provider.{Env, Dotenv}

  @impl true
  def start(_type, _args) do
    load_system_env()
    Node.set_cookie(get_cookie())

    ExRay.Store.create()
    Metrics.Setup.setup()
    MassaProxy.Supervisor.start_link([])
  end

  defp load_system_env() do
    template_root_path = :code.priv_dir(:massa_proxy)

    providers = [
      %Dotenv{},
      %Env{
        bindings: [
          {:proxy_cookie, "NODE_COOKIE", default: "massa_proxy", required: false},
          {:proxy_root_template_path, "PROXY_ROOT_TEMPLATE_PATH",
           default: template_root_path, required: false},
          {:proxy_cluster_strategy, "PROXY_CLUSTER_STRATEGY", default: "gossip", required: false},
          {:proxy_headless_service, "PROXY_HEADLESS_SERVICE",
           default: "proxy-headless-svc", required: false},
          {:proxy_app_name, "PROXY_APP_NAME", default: "massa-proxy", required: false},
          {:proxy_cluster_poling_interval, "PROXY_CLUSTER_POLLING",
           default: 3_000, map: &String.to_integer/1, required: false},
          {:proxy_port, "PROXY_PORT", default: 9000, map: &String.to_integer/1, required: false},
          {:proxy_http_port, "PROXY_HTTP_PORT",
           default: 9001, map: &String.to_integer/1, required: false},
          {:user_function_host, "USER_FUNCTION_HOST", default: "0.0.0.0", required: false},
          {:user_function_port, "USER_FUNCTION_PORT",
           default: 8080, map: &String.to_integer/1, required: false},
          {:user_function_uds_enable, "PROXY_UDS_MODE", default: false, required: false},
          {:user_function_sock_addr, "PROXY_UDS_ADDRESS",
           default: "/var/run/cloudstate.sock", required: false},
          {:heartbeat_interval, "PROXY_HEARTBEAT_INTERVAL",
           default: 240_000, map: &String.to_integer/1, required: false}
        ]
      }
    ]

    config = Vapor.load!(providers)

    set_vars(config)
  end

  defp set_vars(config) do
    Application.put_env(:massa_proxy, :proxy_cookie, config.proxy_cookie)
    Application.put_env(:massa_proxy, :proxy_cluster_strategy, config.proxy_cluster_strategy)
    Application.put_env(:massa_proxy, :proxy_headless_service, config.proxy_headless_service)
    Application.put_env(:massa_proxy, :proxy_app_name, config.proxy_app_name)
    Application.put_env(:massa_proxy, :proxy_root_template_path, config.proxy_root_template_path)

    Application.put_env(
      :massa_proxy,
      :proxy_cluster_poling_interval,
      config.proxy_cluster_poling_interval
    )

    Application.put_env(:massa_proxy, :proxy_port, config.proxy_port)
    Application.put_env(:massa_proxy, :proxy_http_port, config.proxy_http_port)
    Application.put_env(:massa_proxy, :user_function_host, config.user_function_host)
    Application.put_env(:massa_proxy, :user_function_port, config.user_function_port)
    Application.put_env(:massa_proxy, :user_function_uds_enable, config.user_function_uds_enable)
    Application.put_env(:massa_proxy, :user_function_sock_addr, config.user_function_sock_addr)
    Application.put_env(:massa_proxy, :heartbeat_interval, config.heartbeat_interval)
  end

  defp get_cookie(), do: String.to_atom(Application.get_env(:massa_proxy, :proxy_cookie))
end
