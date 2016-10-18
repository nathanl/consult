defmodule Consult.TokenTest do
  use ExUnit.Case

  test "signs and verifies an integer user id" do
    user_id = :rand.uniform(10_000)
    token = Consult.Token.sign_user_id(user_id)
    assert user_id == Consult.Token.verify_user_id(token)
  end

  test "signs and verifies a string user id" do
    user_id = "foo@bar.com"
    token = Consult.Token.sign_user_id(user_id)
    assert user_id == Consult.Token.verify_user_id(token)
  end

  test "signs and verifies a nil user id" do
    user_id = nil
    token = Consult.Token.sign_user_id(user_id)
    assert user_id == Consult.Token.verify_user_id(token)
  end

  test "signs and verifies an integer conversation id" do
    conversation_id = :rand.uniform(10_000)
    token = Consult.Token.sign_conversation_id(conversation_id)
    assert conversation_id == Consult.Token.verify_conversation_id(token)
  end

  test "signs and verifies string conversation id that contains an integer" do
    conversation_id = :rand.uniform(10_000) |> Integer.to_string
    token = Consult.Token.sign_conversation_id(conversation_id)
    assert conversation_id == Consult.Token.verify_conversation_id(token)
  end

  test "will not sign a nil conversation id" do
    assert_raise Consult.Token.InvalidConversationId, fn ->
      Consult.Token.sign_conversation_id(nil)
    end
  end

  test "gives a helpful error if the conversation token is invalid" do
    assert_raise Consult.Token.InvalidConversationToken, fn ->
      Consult.Token.verify_conversation_id("a_bogus_token")
    end
  end
end
