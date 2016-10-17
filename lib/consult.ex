defmodule Consult do
  use Application
  import Supervisor.Spec

  def start(_type, _args) do
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

  defmodule ConfigError do
    defexception message: "missing config value for :consult"
  end

  def repo do
    Application.get_env(
      :consult,
      :repo
    ) || config_error(:repo)
  end

  def endpoint do
    Application.get_env(
      :consult,
      :endpoint
    ) || config_error(:endpoint)
  end

  def hooks_module do
    Application.get_env(
      :consult,
      :hooks_module
    ) || config_error(:hooks_module)
  end

  defp config_error(name) do
    raise ConfigError, message: "missing config value '#{name}' for :consult"
  end


end
