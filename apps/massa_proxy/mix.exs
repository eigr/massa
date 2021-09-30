defmodule MassaProxy.MixProject do
  use Mix.Project

  def project do
    [
      app: :massa_proxy,
      version: "0.1.0",
      elixir: "~> 1.12",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [
        :logger,
        :observer
      ],
      mod: {MassaProxy, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Base deps
      {:bakeware, "~> 0.2"},
      {:cloudstate_protocol, in_umbrella: true},
      {:injectx, "~> 0.1"},
      {:wasmex, "~> 0.5"},
      {:toml, "~> 0.6", override: true},
      {:flow, "~> 1.0"},
      {:vapor, "~> 0.10"},

      # Grpc deps
      {:protobuf, "~> 0.8.0-beta.1", override: true},
      {:grpc, github: "elixir-grpc/grpc", override: true},
      {:cowlib, "~> 2.11", override: true},
      {:grpc_prometheus, "~> 0.1"},
      {:jason, "~> 1.2"},

      # Cluster deps
      {:libcluster, "~> 3.3"},
      {:horde, "~> 0.8"},
      {:phoenix_pubsub, "~> 2.0"},
      {:nebulex, "~> 2.1"},
      {:ranch, "~> 1.8"},

      # Observability deps
      {:ex_ray, "~> 0.1"},
      {:hackney, "~> 1.16"},
      {:prometheus, "~> 4.6"},
      {:prometheus_plugs, "~> 1.1"},
      {:telemetry, "~> 0.4.3"},

      # Http facilities
      {:plug_cowboy, "~> 2.3"},
      {:poison, "~> 5.0"},

      # Best practices
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:churn, "~> 0.1", only: :dev}
    ]
  end

  defp releases() do
    [
      massa_proxy: [
        include_executables_for: [:unix],
        applications: [runtime_tools: :permanent],
        steps: [
          :assemble,
          &Bakeware.assemble/1
        ],
        bakeware: [compression_level: 19]
      ]
    ]
  end
end
