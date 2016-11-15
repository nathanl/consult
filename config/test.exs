use Mix.Config

config :consult,
  ecto_repos: [TestApp.Repo]

config :consult, TestApp.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "consult_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :consult, TestApp.Endpoint, secret_key_base: "abc123"
config :consult, :endpoint, TestApp.Endpoint
config :consult, :repo, TestApp.Repo
config :consult, :presence_module, TestApp.Presence

config :logger, level: :warn
