defmodule Ratekeeper.MixProject do
  use Mix.Project

  def project do
    [
      app: :ratekeeper,
      version: "0.2.4",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      source_url: "https://github.com/whitered/ratekeeper",
      homepage_url: "https://github.com/whitered/ratekeeper",
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Ratekeeper.Application, []}
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp description do
    "Ratekeeper is a library for scheduling rate-limited actions."
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Dmitry Zhelnin"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/whitered/ratekeeper"}
    ]
  end
end
