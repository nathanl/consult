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
