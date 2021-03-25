defmodule MassaProxy.Application do
  @moduledoc false
  use Application
  alias Vapor.Provider.{Env, Dotenv}

  @impl true
  def start(_type, _args) do
    load_system_env()

    ExRay.Store.create()
    Metrics.Setup.setup()
    MassaProxy.Supervisor.start_link([])
  end

  defp load_system_env() do
    providers = [
      %Dotenv{},
      %Env{
        bindings: [
          {:proxy_port, "PROXY_PORT", default: 9000, map: &String.to_integer/1, required: false},
          {:proxy_http_port, "PROXY_HTTP_PORT",
           default: 9001, map: &String.to_integer/1, required: false},
          {:user_function_host, "USER_FUNCTION_HOST", default: "0.0.0.0", required: false},
          {:user_function_port, "USER_FUNCTION_PORT",
           default: 8080, map: &String.to_integer/1, required: false},
          {:user_function_uds_enable, "PROXY_UDS_MODE", default: false, required: false},
          {:user_function_sock_addr, "PROXY_UDS_ADDRESS",
           default: "/var/run/cloudstate.sock", required: false},
          {:heartbeat_interval, "PROXY_HEARTBEAT_INTERVAL", default: 240_000, required: false}
        ]
      }
    ]

    config = Vapor.load!(providers)

    set_vars(config)
  end

  defp set_vars(config) do
    Application.put_env(:massa_proxy, :proxy_port, config.proxy_port)
    Application.put_env(:massa_proxy, :proxy_http_port, config.proxy_http_port)
    Application.put_env(:massa_proxy, :user_function_host, config.user_function_host)
    Application.put_env(:massa_proxy, :user_function_port, config.user_function_port)
    Application.put_env(:massa_proxy, :user_function_uds_enable, config.user_function_uds_enable)
    Application.put_env(:massa_proxy, :user_function_sock_addr, config.user_function_sock_addr)
    Application.put_env(:massa_proxy, :heartbeat_interval, config.heartbeat_interval)
  end
end
