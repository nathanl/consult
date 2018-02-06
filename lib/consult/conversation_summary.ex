defmodule Consult.ConversationSummary do
  alias Consult.Conversation
  alias Conversation.{Scopes, Filters}
  require Ecto.Query
  # TODO make configurable
  @closed_conversation_count 10

  def html(user_id) do
    {:safe, html_iodata} =
      Phoenix.View.render(
        Consult.ConversationView,
        "index.html",
        conversations: conversations(user_id)
      )

    :erlang.iolist_to_binary(html_iodata)
  end

  def conversations(user_id) do
    query = Conversation |> Scopes.id_and_message_info()
    ongoing = ongoing_conversations(query)

    {mine, others} =
      Enum.partition(ongoing, fn conv ->
        conv.owned_by_id == user_id
      end)

    [
      {"Unanswered", unanswered_conversations(query)},
      {"Owned by Me", mine},
      {"Owned by Other Reps", others},
      {"Ended", ended_conversations(query)}
    ]
  end

  defp unanswered_conversations(query) do
    query
    |> Scopes.not_ended()
    |> Scopes.sequential()
    |> Consult.repo().all
    |> Filters.unanswered()
  end

  defp ongoing_conversations(query) do
    query
    |> Scopes.not_ended()
    |> Scopes.sequential()
    |> Consult.repo().all
    |> Filters.ongoing()
  end

  defp ended_conversations(query) do
    query
    |> Scopes.ended()
    |> Scopes.reverse_sequential()
    |> Ecto.Query.limit(@closed_conversation_count)
    |> Consult.repo().all
  end
end
