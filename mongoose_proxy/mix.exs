defmodule MongooseProxy.MixProject do
  use Mix.Project

  def project do
    [
      app: :mongoose_proxy,
      version: "0.1.0",
      elixir: "~> 1.11-dev",
      # elixir: "1.9.0-rc.0",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [
        :logger,
        :observer
      ],
      mod: {MongooseProxyApplication, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:grpc, github: "elixir-grpc/grpc"},
      # 2.9.0 fixes some important bugs, so it's better to use ~> 2.9.0
      {:cowlib, "~> 2.9.0", override: true},
      # Data ingestion for Eventing support
      {:broadway, "~> 0.6.1"},
      # Node discovery for Kubernetes
      {:libcluster, "~> 3.2.1"},
      # Cluster features/utilities
      {:horde, "~> 0.7.1"}
    ]
  end
end
