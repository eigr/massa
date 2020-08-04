defmodule MongooseProxy.MixProject do
  use Mix.Project

  def project do
    [
      app: :mongoose_proxy,
      version: "0.1.0",
      elixir: "~> 1.10",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [
        mongoose_proxy: [
          include_executables_for: [:unix],
          applications: [runtime_tools: :permanent]
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [
        :logger,
        :observer
      ],
      mod: {MongooseProxy.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Base deps
      {:flow, "~> 1.0"},
      {:google_protos, "~> 0.1.0"},

      # Grpc deps
      {:grpc, github: "elixir-grpc/grpc"},
      #{:gun, "~> 2.0", hex: :grpc_gun, override: true},
      # 2.9.0 fixes some important bugs, so it's better to use ~> 2.9.0
      {:cowlib, "~> 2.9.0", override: true},

      # Cluster deps
      # Node discovery for Kubernetes
      {:libcluster, "~> 3.2.1"},
      # Cluster features/utilities
      {:horde, "~> 0.7.1"},

      # Observability deps
      # OpenTracing
      {:ex_ray, "~> 0.1.4"},
      {:hackney, "~> 1.16"},
      # Metrics
      {:prometheus, "~> 4.6"},
      {:prometheus_plugs, "~> 1.1"},

      # Http facilities
      {:plug_cowboy, "~> 2.3"},
      {:poison, "~> 4.0"}
    ]
  end
end
