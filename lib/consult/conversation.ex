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
      query = with_last_message_time_from_role(query, "representative")
      from [conv, last_representative_message] in query,
      left_join: messages in fragment(
      """
      (SELECT
      conversation_id, sender_name, content,
      row_number() OVER (PARTITION BY conversation_id ORDER BY id ASC) as row
      FROM consult_messages
      )
      """
      ),
      on: (messages.conversation_id == conv.id and messages.row == 1),
      left_join: tags in assoc(conv, :tags),
      preload: [tags: tags],
      select: %{
        conv: conv,
        id: conv.id,
        last_representative_message: last_representative_message.last_rep_message_at,
        tags: [tags],
        first_message: %{
          sender_name: messages.sender_name,
          content: messages.content
        }
      }
    end

    # grab info about the first and last message in this conversation,
    # from a user with this role
    def with_messages_snapshot_from_role(query, role) do
      from conv in query,
      left_join: last_message_from_role in fragment(
      """
      (
        SELECT conversation_id,
        first_value(inserted_at) OVER w AS first_message_time,
        last_value(inserted_at)  OVER w AS last_message_time,
        first_value(content)     OVER w AS first_message_content,
        last_value(content)      OVER w AS last_message_content
        FROM consult_messages cm
        WHERE cm.sender_role = ? 
        WINDOW w AS (
          PARTITION BY conversation_id
          ORDER BY id ASC
        )
      )
      """,
      ^role),
      on: last_message_from_role.conversation_id == conv.id
    end

    def select_stuff(query) do
      from [conv, messages_snapshot] in query,
      select: %{
        id: conv.id,
        first_inserted: messages_snapshot.first_message_time,
        last_inserted: messages_snapshot.last_message_time,
        first_content: messages_snapshot.first_message_content,
        last_content: messages_snapshot.last_message_content,
      }
    end
# SELECT  
#     cstamp,
#     price,
#     date_trunc('hour',cstamp) AS h,
#     floor(EXTRACT(minute FROM cstamp) / 5) AS m5,
#     min(price) OVER w,
#     max(price) OVER w,
#     first_value(price) OVER w,
#     last_value(price) OVER w
# FROM trades
# Where date_trunc('hour',cstamp) = timestamp '2013-03-29 09:00:00'
# WINDOW w AS (
#     PARTITION BY date_trunc('hour',cstamp) , floor(extract(minute FROM cstamp) / 5)
#     ORDER BY cstamp
#     range between unbounded preceding and unbounded following
#     )
# ORDER BY cstamp;


    def with_last_message_time_from_role(query, role) do
      from conv in query,
      left_join: last_message_from_role in fragment(
      """
      (
        SELECT MAX(cm.inserted_at) AS last_rep_message_at, cm.conversation_id
        FROM consult_messages AS cm
        WHERE cm.sender_role = ?
        GROUP BY conversation_id
      )
      """, ^role),
      on: last_message_from_role.conversation_id == conv.id
    end

  end

  # After query (find way to do these things in query)
  defmodule Filters do
  # TODO find way to make these part of query
    def unanswered(conversations) do
      conversations |> Enum.filter(fn (conversation) ->
        is_nil(conversation.last_representative_message)
      end)
    end

    def ongoing(conversations) do
      conversations |> Enum.filter(fn (conversation) ->
        !is_nil(conversation.last_representative_message)
      end)
    end
  end

end
