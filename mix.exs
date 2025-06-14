defmodule Barcoder.MixProject do
  use Mix.Project

  def project do
    [
      app: :barcoder,
      version: "0.1.0",
      elixir: "~> 1.18",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "Production-Ready Code 39 Barcode Generator"
  end

  defp package() do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/alekpopovic/barcoder"}
    ]
  end
end
