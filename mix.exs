defmodule Zephyr.MixProject do
  use Mix.Project

  def project do
    [
      app: :zephyr,
      version: "1.0.0-alpha.1",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: [
        licenses: ["Apache-2.0"],
        links: %{"GitHub" => "https://github.com/dgigafox/zephyr"}
      ],
      description:
        "Elixir authorization system based on the ReBAC (Relationship-based Access Control) model"
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
      {:ecto_sql, "~> 3.10"},
      {:credo, "~> 1.7.7", only: [:test, :dev], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
