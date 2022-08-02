defmodule CloudstateProtocol.MixProject do
  use Mix.Project

  def project do
    [
      app: :cloudstate_protocol,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.12",
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
      {:google_protos, "~> 0.3.0"},
      {:protobuf, ">= 0.0.0"},
      {:grpc, github: "elixir-grpc/grpc", override: true},
      {:cowlib, ">= 0.0.0"}
    ]
  end
end
