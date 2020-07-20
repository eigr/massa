import Config

# Our Logger general configuration
config :logger,
  backends: [:console],
  compile_time_purge_level: :debug

# Our Console Backend-specific configuration
config :logger, :console,
  format: "\n$date $time [$node]:[$metadata]:[$level]:$levelpad$message\n",
  metadata: [:pid]

config :mongoose_proxy, :user_function_port, "8080"
