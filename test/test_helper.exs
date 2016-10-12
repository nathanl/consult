ExUnit.start()

Ecto.Migrator.run(TestApp.Repo, "priv/repo/migrations", :up, all: true)
Ecto.Adapters.SQL.Sandbox.mode(TestApp.Repo, :manual)
