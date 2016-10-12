defmodule Consult.ConversationTag do
  use Ecto.Schema
  import Ecto
  import Ecto.Changeset
  import Ecto.Query
  alias Consult.{Conversation,ConversationTag,Tag}

  schema "consult_conversations_tags" do
    belongs_to :conversation, Conversation
    belongs_to :tag, Tag

    timestamps
  end
  @ids [:conversation_id, :tag_id]

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @ids)
    |> validate_required(@ids)
  end

  def updates_for(existing_taggings, conversation_id, desired_tag_ids) do
    # Convert any string params to integers - ugly, but works
    conversation_id = as_int(conversation_id)
    desired_tag_ids = desired_tag_ids |> Enum.map(&as_int/1)

    existing_tagging_conversation_ids = existing_taggings |> Enum.map(&(&1.conversation_id))
    cond do
      (existing_tagging_conversation_ids |> Enum.uniq |> Enum.count) > 1 ->
        {:error, "existing ConversationTags are not all for the same conversation"}
      !(Enum.all?(existing_tagging_conversation_ids, &(&1 == conversation_id))) ->
        {:error, "conversation_id doesn't match given ConversationTags"}
      true ->
        existing_tag_ids = existing_taggings |> Enum.map(&(&1.tag_id))
        adds = (desired_tag_ids -- existing_tag_ids) |> Enum.map(fn (new_tag_id) ->
          %ConversationTag{conversation_id: conversation_id, tag_id: new_tag_id}
        end)
        deletes = Enum.filter(existing_taggings, fn (existing_tagging) ->
          !Enum.member?(desired_tag_ids, existing_tagging.tag_id)
        end)
        {:ok, deletes, adds}
    end
  end

  def as_int(val) when is_binary(val) do
    {intval,  ""} = Integer.parse(val)
    intval
  end

  def as_int(val) when is_integer(val), do: val

end
