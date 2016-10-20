defmodule Consult.ConversationTest do
  use Consult.ModelCase
  alias Consult.Conversation

  describe "id_and_message_info/1" do

    @tag :skip
    test "can get a conversation with all its tags" do
      inserted_id = (TestApp.Repo.insert!(Fixtures.conversation_with_tags(["bug", "bad"]))).id
      fetched = (Ecto.Query.from c in Conversation, where: c.id == ^inserted_id)
      |> Conversation.Scopes.id_and_message_info |> Consult.repo.one
      assert Enum.map(fetched.tags, fn (tag) -> tag.name end) == ["bug", "bad"]
    end
  end

end
