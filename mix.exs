defmodule Max1704x.MixProject do
  @moduledoc "Driver for the MAX17040 and MAX17041 lithium battery monitoring ICs"
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :max1704x,
      version: @version,
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      description: @moduledoc,
      deps: deps(),
      package: package(),
      docs: [
        main: "readme",
        extras: ["README.md", "CHANGELOG.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def package do
    [
      maintainers: ["James Harton <james@harton.nz>"],
      licenses: ["HL3-FULL"],
      links: %{
        "Source" => "https://harton.dev/james/max1704x",
        "GitHub" => "https://github.com/jimsynz/max1704x",
        "Changelog" => "https://docs.harton.nz/james/max1704x/changelog.html",
        "Sponsor" => "https://github.com/sponsors/jimsynz"
      }
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Required
      {:spark, "~> 2.1"},
      {:wafer, "~> 1.0"},

      # Optional
      {:circuits_i2c, "< 3.0.0", optional: true},

      # Dev/test
      {:credo, "~> 1.6", only: ~w[dev test]a, runtime: false},
      {:dialyxir, "~> 1.4", only: ~w[dev test]a, runtime: false},
      {:doctor, "~> 0.22", only: ~w[dev test]a, runtime: false},
      {:elixir_ale, "~> 1.2", optional: true},
      {:ex_check, "~> 0.16", only: ~w[dev test]a, runtime: false},
      {:ex_doc, "~> 0.40", only: ~w[dev test]a, runtime: false},
      {:git_ops, "~> 2.4", only: ~w[dev test]a, runtime: false},
      {:mimic, "~> 2.0", only: :test}
    ]
  end
end
