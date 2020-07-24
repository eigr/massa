import Config

# Our Logger general configuration
config :logger,
  backends: [:console],
  compile_time_purge_level: :debug

# Our Console Backend-specific configuration
config :logger, :console,
  format: "$date $time [$node]:[$metadata]:[$level]:$levelpad$message\n",
  metadata: [:pid]

config :libcluster,
  topologies: [
    dev: [
      strategy: Cluster.Strategy.Epmd,
      config: [
        hosts: [
          :"a@127.0.0.1",
          :"b@127.0.0.1",
          :"c@127.0.0.1"
        ]
      ]
    ]
  ]

# OpenTracing configs
config :otter,
  zipkin_collector_uri: 'http://127.0.0.1:9411/api/v1/spans',
  zipkin_tag_host_service: "mongoose_proxy",
  http_client: :hackney

config :mongoose_proxy,
  proxy_port: 9000,
  proxy_http_port: 9001,
  user_function_host: "127.0.0.1",
  user_function_port: "8080",
  user_function_uds_enable: true,
  user_function_sock_addr: "/var/run/cloudstate.sock",
  heartbeat_interval: 60_000
