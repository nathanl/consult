defmodule Consult.ConversationSourceTest do
  use Consult.ModelCase
  alias Consult.{Conversation,ConversationSource}

  test "creates a new conversation if the token is null" do
    conversation = TestApp.Repo.insert!(Fixtures.new_conversation)
    new_id = ConversationSource.id_for("null")
    assert new_id == conversation.id + 1
  end

  test "uses the specified conversation if the token is valid" do
    conversation = TestApp.Repo.insert!(Fixtures.new_conversation)
    token = Consult.Token.sign_conversation_id(conversation.id)
    found_id = ConversationSource.id_for(token)
    assert found_id == conversation.id
  end

  test "creates a new conversation if the specified conversation no longer exists" do
    conversation = TestApp.Repo.insert!(Fixtures.new_conversation)
    token = Consult.Token.sign_conversation_id(conversation.id)
    Consult.repo.delete(conversation)
    new_id = ConversationSource.id_for(token)
    assert new_id == conversation.id + 1
  end

  test "raises a helpful error if the token is invalid" do
    assert_raise Consult.Token.InvalidConversationToken, fn () ->
      ConversationSource.id_for("a_bogus_token")
    end
  end

end
