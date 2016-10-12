defmodule Consult.ConversationTagTest do
  use Consult.ModelCase

  alias Consult.ConversationTag

  test "updates_for/3 lists associations to add and delete" do
    # Suppose we have a conversation
    conversation_id = 1

    # ...and the conversation starts out with some tags
    existing_taggings = ([1,2,3] |> Enum.map(fn (tag_id) ->
      %ConversationTag{conversation_id: conversation_id, tag_id: tag_id}
    end))

    # ...then someone tells us that it should have these tags
    requested_tag_ids = [3,4,5]

    # ...we should be able to see which tags need to be added and deleted
    {:ok, deletes, adds} = ConversationTag.updates_for(existing_taggings, conversation_id, requested_tag_ids)

    #...and they should be these
    assert deletes == [
      %ConversationTag{conversation_id: conversation_id, tag_id: 1},
      %ConversationTag{conversation_id: conversation_id, tag_id: 2},
    ]
    assert adds == [
      %ConversationTag{conversation_id: conversation_id, tag_id: 4},
      %ConversationTag{conversation_id: conversation_id, tag_id: 5},
    ]
  end

  test "updates_for/3 blows up if conversation_ids are not all the same" do
    taggings = [
      %ConversationTag{conversation_id: 1, tag_id: 1},
      %ConversationTag{conversation_id: 2, tag_id: 2},
    ]

    assert {:error, _some_message} = ConversationTag.updates_for(taggings, 1, [1,2])
  end

  test "updates_for/3 blows up if conversation_id doesn't match given taggings" do
    taggings = [
      %ConversationTag{conversation_id: 1, tag_id: 1},
      %ConversationTag{conversation_id: 1, tag_id: 2},
    ]

    assert {:error, _some_message} = ConversationTag.updates_for(taggings, 2, [1,2])
  end

end
