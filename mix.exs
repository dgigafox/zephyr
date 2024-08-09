defmodule Zephyr.MixProject do
  use Mix.Project

  def project do
    [
      app: :zephyr,
      version: "0.1.0",
      elixir: "~> 1.17",
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
      {:ecto_sql, "~> 3.10"},
      {:credo, "~> 1.7.7", only: [:test, :dev], runtime: false}
    ]
  end
end
