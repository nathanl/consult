defmodule Consult.ConversationSummary do
  alias Consult.Hooks
  require Hooks
  alias Consult.Conversation
  alias Conversation.{Scopes,Filters}
  require Ecto.Query
  @closed_conversation_count 10 # TODO make configurable

  def html do
    {:safe, html_iodata} = Phoenix.View.render(
      Consult.ConversationView, "index.html", conversations: conversations
    )
    :erlang.iolist_to_binary(html_iodata)
  end

  def conversations do
    query = Conversation |> Scopes.id_and_message_info

    [
      {"Unanswered", unanswered_conversations(query)},
      {"Ongoing", ongoing_conversations(query)},
      {"Ended", ended_conversations(query)},
    ]
  end

  defp unanswered_conversations(query) do
    query
    |> Scopes.not_ended
    |> Scopes.sequential
    |> Hooks.repo.all
    |> Filters.unanswered
  end

  defp ongoing_conversations(query) do
    query
    |> Scopes.not_ended
    |> Scopes.sequential
    |> Hooks.repo.all
    |> Filters.ongoing
  end

  defp ended_conversations(query) do
    query
    |> Scopes.ended
    |> Scopes.reverse_sequential
    |> Ecto.Query.limit(@closed_conversation_count)
    |> Hooks.repo.all
  end

end
