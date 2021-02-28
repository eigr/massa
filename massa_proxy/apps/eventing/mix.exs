defmodule Eventing.MixProject do
  use Mix.Project

  def project do
    [
      app: :eventing,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.10",
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
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      # {:sibling_app_in_umbrella, in_umbrella: true}

      # Base deps
      {:flow, "~> 1.0"},
      {:protobuf, "~> 0.7.1"},
      {:google_protos, "~> 0.1.0"}

      # Data ingestion deps
      # {:broadway, "~> 0.6.1"}
    ]
  end
end
