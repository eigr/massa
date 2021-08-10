defmodule MassaProxy.Infra.Config.Vapor do
  @behaviour MassaProxy.Infra.Config

  require Logger
  alias Vapor.Provider.{Env, Dotenv}

  @impl true
  def load() do
    case Agent.start_link(fn -> %{} end, name: __MODULE__) do
      {:ok, _pid} ->
        Agent.get_and_update(__MODULE__, fn state ->
          if state == %{} do
            config = load_system_env()
            {config, config}
          else
            {state, state}
          end
        end)

      {:error, {:already_started, _pid}} ->
        Agent.get(__MODULE__, fn state -> state end)
    end
  end

  @impl true
  def get(key), do: Agent.get(__MODULE__, fn state -> Map.get(state, key) end)

  defp load_system_env() do
    priv_root_path = :code.priv_dir(:massa_proxy)
    key_path = Path.expand("./tls/server1.key", :code.priv_dir(:massa_proxy))
    cert_path = Path.expand("./tls/server1.pem", :code.priv_dir(:massa_proxy))

    providers = [
      %Dotenv{},
      %Env{
        bindings: [
          {:proxy_runtime_type, "PROXY_RUNTIME_TYPE", default: "GRPC", required: false},
          {:proxy_cookie, "NODE_COOKIE", default: "massa_proxy", required: false},
          {:proxy_root_template_path, "PROXY_ROOT_TEMPLATE_PATH",
           default: priv_root_path, required: false},
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
           default: 60_000, map: &String.to_integer/1, required: false},
          {:tls, "PROXY_TLS", default: false, required: false},
          {:tls_cert_path, "PROXY_TLS_CERT_PATH", default: cert_path, required: false},
          {:tls_key_path, "PROXY_TLS_KEY_PATH", default: key_path, required: false}
        ]
      }
    ]

    config = Vapor.load!(providers)

    Enum.each(config, fn {key, value} ->
      Logger.debug("Loading config: [#{key}]:[#{value}]")
      Application.put_env(:dispatcher, key, value, persistent: true)
    end)

    config
  end
end
