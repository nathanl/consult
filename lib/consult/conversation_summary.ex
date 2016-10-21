defmodule Consult.ConversationSummary do
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
    not_ended = not_ended(query)

    [
      {"Unanswered", (not_ended |> Filters.unanswered)},
      {"Ongoing", (not_ended |> Filters.ongoing)},
      {"Ended", ended_conversations(query)},
    ]
  end

  def not_ended(query) do
    query
    |> Scopes.not_ended
    |> Scopes.sequential
    |> Consult.repo.all
  end

  defp ended_conversations(query) do
    query
    |> Scopes.ended
    |> Scopes.reverse_sequential
    |> Ecto.Query.limit(@closed_conversation_count)
    |> Consult.repo.all
  end

end
