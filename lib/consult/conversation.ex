defmodule Consult.Conversation do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "consult_conversations" do
    has_many :messages, Consult.Message
    has_many :conversation_tags, Consult.ConversationTag
    many_to_many :tags, Consult.Tag, join_through: Consult.ConversationTag
    field :ended_at, Ecto.DateTime

    timestamps
  end

  @allowed_params ~w(ended_at)
  
  def changeset(conversation, params \\ %{}) do
    conversation |>
    cast(params, @allowed_params)
  end

  def end_now(conversation) do
    changeset(conversation, %{ended_at: Ecto.DateTime.utc})
  end

  def ended?(conversation) do
    not is_nil(conversation.ended_at)
  end

  defmodule Scopes do

    def not_ended(query) do
      from c in query, where: is_nil(c.ended_at)
    end

    def ended(query) do
      from c in query, where: not is_nil(c.ended_at)
    end

    def sequential(query) do
      from c in query, order_by: [asc: c.id]
    end

    def reverse_sequential(query) do
      from c in query, order_by: [desc: c.id]
    end

    def with_conversation_tags(query) do
      from c in query, preload: :conversation_tags
    end

    # Join the first message for each conversation
    def id_and_message_info(query) do
      from conv in query, left_join: messages in fragment(
      """
      (SELECT
      conversation_id, sender_name, content,
      row_number() OVER (PARTITION BY conversation_id ORDER BY id ASC) as row
      FROM consult_messages
      )
      """
      ),
      on: (messages.conversation_id == conv.id and messages.row == 1),
      # TODO - find some way to make separate scopes for "1 participant" and
      # "more than one", for answered vs unanswered chats
      left_join: participants in fragment(
      """
      (SELECT
      conversation_id,
      -- COUNT DISTINCT ignores nulls, hence the COALESCE
      -- this handles the case where there is at least one message,
      -- but it has no sender_id; call it '0' so we can count
      -- it as one unique participant
      COUNT(DISTINCT COALESCE(sender_id, 0)) AS participant_count
      FROM consult_messages
      GROUP BY conversation_id
      )
      """
      ), on: participants.conversation_id == conv.id,
      left_join: tags in assoc(conv, :tags),
      preload: [tags: tags],
      select: %{
        conv: conv,
        id: conv.id,
        participant_count: participants.participant_count,
        tags: [tags],
        first_message: %{
          sender_name: messages.sender_name,
          content: messages.content
        }
      }
    end

  end

  # After query (find way to do these things in query)
  defmodule Filters do
  # TODO find way to make these part of query
    def unanswered(conversations) do
      conversations |> Enum.filter(fn (conversation) ->
        conversation.participant_count == 1
      end)
    end

    def ongoing(conversations) do
      conversations |> Enum.filter(fn (conversation) ->
        # If there are no messages, participant_count will come back
        # nil from the query
        (conversation.participant_count || 0) > 1
      end)
    end
  end

end
