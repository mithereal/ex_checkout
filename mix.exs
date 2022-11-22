defmodule ExCheckout.MixProject do
  use Mix.Project

  @version "1.0.0"

  def project do
    [
      app: :ex_checkout,
      version: @version,
      elixir: "~> 1.13",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      description: description(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
#      [extra_applications: [:logger], mod: {ExCheckout.Application, []}]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.14", only: :dev},
      {:credo, "~> 0.9.1", only: [:dev, :test], runtime: false},
      {:inch_ex, ">= 0.0.0", only: :docs}
    ]
  end

  defp description do
    "E-commerce Checkout for Elixir."
  end

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
end
