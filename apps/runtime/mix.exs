defmodule Runtime.MixProject do
  use Mix.Project

  def project do
    [
      app: :runtime,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Runtime, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cloudstate_protocol, in_umbrella: true},
      {:eigr_protocol, in_umbrella: true},
      {:injectx, "~> 0.1"},
      {:flow, "~> 1.0"},
      {:protobuf, "~> 0.9.0", override: true},
      {:grpc, github: "elixir-grpc/grpc", override: true},
      {:cowlib, "~> 2.11", override: true},
      {:grpc_prometheus, "~> 0.1"},
      {:jason, "~> 1.2"},
      {:toml, "~> 0.6", override: true},
      {:prometheus, "~> 4.6"},
      {:prometheus_plugs, "~> 1.1"},
      {:telemetry, "~> 0.4.3"},
      {:phoenix_pubsub, "~> 2.0"}
    ]
  end
end
