defmodule Posthoern.MixProject do
  use Mix.Project

  def project do
    [
      app: :posthoern,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description:
        "Multi-tenant support-mail relay: forwards opaque report bundles as email attachments.",
      licenses: ["LGPL-3.0-or-later"]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Posthoern.Application, []}
    ]
  end

  defp deps do
    [
      {:bandit, "~> 1.0"},
      {:plug, "~> 1.16"}
    ]
  end

  defp package do
    [
      licenses: ["LGPL-3.0-or-later"],
      files: ~w(lib config mix.exs COPYING COPYING.LESSER AGENTS.md)
    ]
  end
end
