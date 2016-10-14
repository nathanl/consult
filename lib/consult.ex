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

  def children_for_environment(_) do
    []
  end

  def repo do
    Application.get_env(:consult, :repo)
  end

  def endpoint do
    Application.get_env(:consult, :repo)
  end

  def hooks do
    Application.get_env(:consult, :hooks_module)
  end

end
