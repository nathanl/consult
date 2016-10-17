defmodule Consult.Mixfile do
  use Mix.Project

  @version "0.0.1"

  def project do
    [
      app: :consult,
      version: @version,
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.3",
      elixirc_paths: elixirc_paths(Mix.env),
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      compilers: [:phoenix] ++ Mix.compilers,
      deps: deps,

      # For ExDoc
      name: "Consult",
      docs: [
        extras: ["README.md"],
        main: "readme",
        source_ref: "v#{@version}",
        source_url: "https://github.com/nathanl/consult",
        homepage_url: "https://github.com/nathanl/consult",
      ],
    ]
  end

  def package do
    [
      maintainers: ["Nathan Long - him@nathanmlong.com"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/nathanl/swappy"}
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      mod: {Consult, []},
      applications: [
        :logger,
        :phoenix,
        :phoenix_pubsub,
        :phoenix_html,
        :phoenix_ecto,
        :postgrex,
      ],
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # To depend on another app inside the umbrella:
  #
  #   {:myapp, in_umbrella: true}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:phoenix, "~> 1.2"},
      {:phoenix_html, "~> 2.6"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:ex_doc, "~> 0.10", only: :dev},
      {:earmark, ">= 0.0.0", only: :dev},
    ]
  end

  defp elixirc_paths(:test) do
    elixirc_paths(:dev) ++ ["test/support"]
  end

  defp elixirc_paths(_) do
    ["lib", "web"]
  end
end
