defmodule Consult.ConversationTest do
  use Consult.ModelCase
  alias Consult.Conversation

  describe "id_and_message_info/1" do

    @tag :skip
    test "can get a conversation with all its tags" do
      inserted = TestApp.Repo.insert!(Fixtures.conversation_with_tags(["bug", "bad"]))
      fetched = Conversation.Scopes.with_id(633) |> Conversation.Scopes.id_and_message_info |> IO.inspect |> Consult.repo.one
      # Ecto.Adapters.SQL.to_sql(:all, Consult.repo, fetched) |> IO.inspect
      assert Enum.map(fetched.tags, fn (tag) -> tag.name end) == ["bug", "bad"]
    end
  end

end
