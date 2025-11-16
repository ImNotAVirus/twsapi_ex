defmodule TWSAPIEx.MixProject do
  use Mix.Project

  def project() do
    [
      app: :twsapi_ex,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      preferred_cli_env: [ci: :test],
      aliases: aliases(),
      elixirc_options: [warnings_as_errors: true]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application() do
    [
      extra_applications: [:logger],
      mod: {TWSAPIEx.Application, []}
    ]
  end

  def aliases() do
    [
      tidewave:
        "run --no-halt -e 'Agent.start(fn -> Bandit.start_link(plug: Tidewave, port: 4000) end)'",
      ci: ["format", "credo", "test"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps() do
    [
      {:simple_enum, github: "imnotavirus/simple_enum"},
      {:elvengard_network, github: "elvengard-mmo/elvengard_network"},
      # {:elvengard_network, path: "../elvengard_network"},

      ## Dev
      {:tidewave, "~> 0.5", only: :dev},
      {:bandit, "~> 1.0", only: :dev},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end
end
