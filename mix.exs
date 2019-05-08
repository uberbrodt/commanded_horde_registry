defmodule Commanded.Registration.HordeRegistry.MixProject do
  use Mix.Project

  def project do
    [
      app: :commanded_horde_registry,
      aliases: [
        test: "test --no-start"
      ],
      version: "0.1.0",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      docs: docs(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    "A Commanded.Registration implementation using Horde as a distributed process registry"
  end

  defp docs() do
    [main: Commanded.Registration.HordeRegistry]
  end

  defp elixirc_paths(:test) do
    [
      "lib",
      "test/support",
      "deps/commanded/test/registration/support",
      "deps/commanded/test/support"
    ]
  end

  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      # files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Chris Brodt"],
      licenses: ["MIT"],
      source_url: "https://github.com/uberbrodt/commanded_horde_registry",
      links: %{"Github" => "https://github.com/uberbrodt/commanded_horde_registry"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:commanded, git: "https://github.com/uberbrodt/commanded", tag: "aggregate_sup_adapter", runtime: Mix.env() == :test},
      {:jason, "~> 1.1"},
      {:ex_doc, "~> 0.19", only: :dev},
      {:horde, "~> 0.5.0"},
      {:local_cluster, "~> 1.0", only: [:test]},
      {:mox, "~> 0.5", only: :test}
    ]
  end
end
