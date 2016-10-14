defmodule Mix.Tasks.Consult.ShowExpectedStructure do
  use Mix.Task

  # @moduledoc "Copy Consult migrations to consuming app, and stuff"
  @shortdoc "Show the expected table structure for Consult data"
  def run(_args) do
    IO.puts """
    Consult needs a table structure like the following. Either create a
    migration like this, or adjust your schema to match.

    The data for some fields, like consult_messages.sender_id and .sender_name,
    will be supplied by your application, so you may want to adjust their types
    or lengths accordingly. Note that consult_messages.sender_id is nullable,
    based on the assumption that some (most?) chat users will not be logged in
    to your application.

    Also, if you intend to query this data in ways that Consult doesn't do
    already, you may want more or different indexes (eg, to support full-text
    search of message contents).
    -----
    """
    this_dir = Path.dirname(__ENV__.file)
    path = "#{this_dir}/../../../priv/repo/migrations/20161012152539_create_consult_tables.exs"
    contents = File.read!(path)
    IO.puts contents
  end
end
