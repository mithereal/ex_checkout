defmodule ExCheckout.MixProject do
  use Mix.Project

  @version "1.5.3"
  @source_url "https://github.com/mithereal/ExCheckout"

  def project do
    [
      app: :ex_checkout,
      version: @version,
      elixir: "~> 1.13",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      description: description(),
      deps: deps(),
      docs: docs(),
      elixirc_paths: elixirc_paths(Mix.env()),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [extra_applications: [:logger, :nanoid], mod: {ExCheckout.Application, []}]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:credo, "~> 0.9.1", only: [:dev, :test], runtime: false},
      {:ex_phone_number, "~> 0.3.0"},
      {:ecto, "~> 3.10"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, "~> 0.16"},
      {:nanoid, "~> 2.0"},
      {:decimal, ">= 0.0.0"},
      {:iso, "~> 1.2"},
      {:telemetry, "~> 1.0"},
      {:excoveralls, "~> 0.14", only: [:test, :dev]},
      {:ex_machina, "~> 2.2", only: :test},
      {:faker, "~> 0.16", only: [:test, :dev]},
      {:mock, "~> 0.3.0", only: :test},
      {:inch_ex, ">= 0.0.0", only: :docs},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev, :test], runtime: false},
      {:mix_audit, ">= 0.0.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp description do
    "E-commerce Checkout for Elixir."
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    # These are the default files included in the package
    [
      name: :ex_checkout,
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["Jason Clark"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/mithereal/ex_checkout"}
    ]
  end

  defp docs do
    [
      main: "ExCheckout",
      source_url: @source_url,
      extras: ["README.md"]
    ]
  end
end
