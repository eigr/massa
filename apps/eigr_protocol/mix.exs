defmodule EigrProtocol.MixProject do
  use Mix.Project

  def project do
    [
      app: :eigr_protocol,
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
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:google_protos, "~> 0.2.0"},
      {:protobuf, "~> 0.9.0", override: true},
      {:grpc, github: "elixir-grpc/grpc", override: true},
      {:cowlib, "~> 2.11", override: true}
    ]
  end
end
