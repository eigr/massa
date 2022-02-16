import Config

# Our Logger general configuration
config :logger,
  backends: [:console],
  compile_time_purge_matching: [
    [level_lower_than: :debug]
  ]

config :protobuf, extensions: :enabled

# Our Console Backend-specific configuration
config :logger, :console,
  format: "$date $time [$node]:[$metadata]:[$level]:$levelpad$message\n",
  metadata: [:pid]

# Cluster configurations
config :libcluster,
  topologies: [
    kubernetes: [
      strategy: Elixir.Cluster.Strategy.Kubernetes.DNS,
      config: [
        service: "massa-proxy-svc",
        application_name: "massa_proxy",
        polling_interval: 3_000
      ]
    ]
  ]

# OpenTracing configs
config :otter,
  zipkin_collector_uri: 'http://127.0.0.1:9411/api/v1/spans',
  zipkin_tag_host_service: "massa_proxy",
  http_client: :hackney

# Proxy configuration
config :massa_proxy,
  proxy_port: System.get_env("PROXY_PORT") || 9000,
  proxy_http_port: System.get_env("PROXY_HTTP_PORT") || 9001,
  user_function_host: System.get_env("USER_FUNCTION_HOST") || "127.0.0.1",
  user_function_port: System.get_env("USER_FUNCTION_PORT") || 8080,
  user_function_uds_enable: System.get_env("PROXY_UDS_MODE") || true,
  user_function_sock_addr: System.get_env("PROXY_UDS_ADDRESS") || "/var/run/cloudstate.sock",
  heartbeat_interval: System.get_env("PROXY_HEARTBEAT_INTERVAL") || 60_000
