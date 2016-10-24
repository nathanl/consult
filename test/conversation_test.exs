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

    test "it gets the message snapshot stuff" do
      # TestApp.Repo.insert!(Fixtures.ended_conversation)
      inserted_id = (TestApp.Repo.insert!(Fixtures.ended_conversation)).id
      ended = (Ecto.Query.from c in Conversation, where: c.id == ^inserted_id)
              # |> Conversation.Scopes.with_messages_snapshot_from_role("user")
              |> Conversation.Scopes.new_id_and_message_info
              |> Consult.repo.one
              # |> IO.inspect

              # result = Ecto.Adapters.SQL.to_sql(:all, Consult.repo, ended)
              # IO.puts elem(result, 0)

      # Ecto.Adapters.SQL.to_sql(:all, Repo, Post)

      assert ended.first_user_message_name == "Alex"
      assert Regex.match?(~r/How quickly/, ended.first_user_message_content)
      assert ended.last_user_message_name == "Alex"
      assert Regex.match?(~r/probably fine/, ended.last_user_message_content || "")
    end
  end

end
