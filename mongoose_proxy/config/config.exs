import Config

# Our Logger general configuration
config :logger,
  backends: [:console],
  compile_time_purge_level: :debug

# Our Console Backend-specific configuration
config :logger, :console,
  format: "$date $time [$node]:[$metadata]:[$level]:$levelpad$message\n",
  metadata: [:pid]

config :mongoose_proxy,
  user_function_host: "127.0.0.1",
  user_function_port: "8080",
  heartbeat_interval: 15_000
