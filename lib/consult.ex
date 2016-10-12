defmodule Consult do
  use Application
  import Supervisor.Spec

  def start(type, args) do
    # TODO is this an OK way to adjust per environment?
    children = children_for_environment(Mix.env)
    opts = [strategy: :one_for_one, name: Consult.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def children_for_environment(:test) do
    [
      supervisor(TestApp.Endpoint, []),
      supervisor(TestApp.Repo, []),
    ]
  end
end
