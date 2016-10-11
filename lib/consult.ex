defmodule Consult do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(TestApp.Endpoint, []),
    ]

    opts = [strategy: :one_for_one, name: Consult.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
