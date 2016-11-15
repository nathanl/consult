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

  describe "if_unowned_mark_owned_by" do

    test "if the conversation is unowned, it marks it owned by the given user id" do
      inserted_id = TestApp.Repo.insert!(%Conversation{}).id
      Conversation.if_unowned_mark_owned_by(inserted_id, "Nathan")
      fetched = (Ecto.Query.from c in Conversation, where: c.id == ^inserted_id)
      |> Consult.repo.one
      assert fetched.owned_by_id == "Nathan"
    end
  end

  test "if the conversation is owned, it does modify it" do
      inserted_id = TestApp.Repo.insert!(%Conversation{owned_by_id: "Jay"}).id
      Conversation.if_unowned_mark_owned_by(inserted_id, "Nathan")
      fetched = (Ecto.Query.from c in Conversation, where: c.id == ^inserted_id)
      |> Consult.repo.one
      assert fetched.owned_by_id == "Jay"
  end

end
