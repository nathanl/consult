defmodule Consult.TokenTest do
  use ExUnit.Case
  alias Consult.Token

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
    conversation_id = :rand.uniform(10_000) |> Integer.to_string()
    token = Consult.Token.sign_conversation_id(conversation_id)
    assert conversation_id == Consult.Token.verify_conversation_id(token)
  end

  test "will not sign a nil conversation id" do
    assert_raise Consult.Token.InvalidConversationId, fn ->
      Consult.Token.sign_conversation_id(nil)
    end
  end

  test "gives a meaningful error if the conversation token is invalid" do
    assert_raise Consult.Token.InvalidConversationToken, fn ->
      Consult.Token.verify_conversation_id("a_bogus_token")
    end
  end

  test "signs and verifies a user role" do
    role_name = "representative"
    signed = Consult.Token.sign_user_role(role_name)
    verified = Consult.Token.verify_user_role(signed)
    assert verified == role_name
  end

  test "gives a meaningful error if the user role token is invalid" do
    assert_raise Consult.Token.InvalidUserRoleToken, fn ->
      Consult.Token.verify_user_role("a_bogus_role_token")
    end
  end

  test "gives a unique identifier per user" do
    u1 = %{id: nil, name: "User"}
    u2 = %{id: 1, name: "User"}
    r1 = %{id: nil, name: "Rep"}
    r2 = %{id: 2, name: "Rep"}
    identifiers = [u1, u2, r1, r2] |> Enum.map(&Consult.Token.user_identifier/1)
    assert Enum.uniq(identifiers) == identifiers
  end

  test "gives the same identifier every time, regardless of clock time" do
    first = Token.user_identifier(%{id: 1, name: "Ho"})
    :timer.sleep(1)
    second = Token.user_identifier(%{id: 1, name: "Ho"})
    assert first == second
  end
end
