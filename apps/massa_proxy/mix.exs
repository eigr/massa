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
      releases: releases(),
      aliases: [
        test: "test --no-start"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [
        :logger,
        :observer,
        :runtime
      ],
      mod: {MassaProxy, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Base deps
      {:cloudstate_protocol, in_umbrella: true},
      {:eigr_protocol, in_umbrella: true},
      {:runtime, in_umbrella: true},
      {:runtime_grpc, in_umbrella: true},
      {:runtime_wasm, in_umbrella: true},
      {:store, in_umbrella: true},
      {:store_inmemory, in_umbrella: true},
      {:bakeware, "~> 0.2"},
      {:vapor, "~> 0.10"},

      # Cluster deps
      {:libcluster, "~> 3.3"},
      {:horde, "~> 0.8"},
      {:nebulex, "~> 2.1"},
      {:ranch, "~> 1.8"},

      # Observability deps
      {:ex_ray, "~> 0.1"},
      {:hackney, "~> 1.16"},

      # Http facilities
      {:plug_cowboy, "~> 2.3"},
      {:poison, "~> 5.0"},

      # Best practices
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:churn, "~> 0.1", only: :dev},

      # Tests
      {:local_cluster, "~> 1.2", only: [:test]}
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
