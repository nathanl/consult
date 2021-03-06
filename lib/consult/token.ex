defmodule Consult.Token do
  defmodule InvalidConversationId do
    defexception message: "must not be nil"
  end

  defmodule InvalidConversationToken do
    defexception message: "is not valid"
  end

  defmodule InvalidUserRoleToken do
    defexception message: "is not valid"
  end

  def sign_user_id(user_id) do
    Phoenix.Token.sign(Consult.endpoint(), "user_id", user_id)
  end

  def verify_user_id(user_id_token) do
    {:ok, user_id} =
      Phoenix.Token.verify(
        Consult.endpoint(),
        "user_id",
        user_id_token,
        max_age: max_token_age()
      )

    user_id
  end

  def sign_conversation_id(conversation_id) when is_nil(conversation_id) do
    raise InvalidConversationId
  end

  def sign_conversation_id(conversation_id) do
    Phoenix.Token.sign(Consult.endpoint(), "conversation_id", conversation_id)
  end

  def verify_conversation_id(conversation_id_token) do
    case Phoenix.Token.verify(
           Consult.endpoint(),
           "conversation_id",
           conversation_id_token,
           max_age: max_token_age()
         ) do
      {:ok, conversation_id} -> conversation_id
      _ -> raise InvalidConversationToken, message: conversation_id_token
    end
  end

  def sign_user_role(role_name) do
    Phoenix.Token.sign(Consult.endpoint(), "user_role", role_name)
  end

  def verify_user_role(user_role_token) do
    case Phoenix.Token.verify(
           Consult.endpoint(),
           "user_role",
           user_role_token,
           max_age: max_token_age()
         ) do
      {:ok, role_name} -> role_name
      _ -> raise InvalidUserRoleToken, message: user_role_token
    end
  end

  def user_identifier(_user = %{id: id, name: name}) when is_binary(name) and is_integer(id) do
    user_identifer_for(Integer.to_string(id), name)
  end

  def user_identifier(_user = %{id: id, name: name}) when is_binary(name) and is_binary(id) do
    user_identifer_for(id, name)
  end

  def user_identifier(_user = %{id: id, name: name}) when is_binary(name) and is_nil(id) do
    user_identifer_for("nil", name)
  end

  defp user_identifer_for(id, name) do
    # TODO make this the application's secret salt
    salt = "ilikebadgersohyes"
    pre_hash = [salt, id, name] |> :erlang.list_to_binary()
    :crypto.hash(:sha256, pre_hash) |> Base.encode16()
  end

  defp max_token_age() do
    # TODO make configurable
    60 * 60 * 24 * 7
  end
end
