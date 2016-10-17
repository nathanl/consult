defmodule Consult.ChatSessionController do
  use Phoenix.Controller
  alias Consult.Conversation

  plug Consult.Authorized when action in [:give_help]

  def give_help(conn, %{"conversation_id" => conversation_id}) do
    conversation = Consult.repo.get_by(Conversation, id: conversation_id)
    render_data = case conversation do
      nil -> %{error: "The requested conversation does not exist"}
      %Conversation{} ->
        cs_rep = Consult.hooks_module.user_for_request(conn)
        user_id_token = user_id_token(cs_rep.id)
        conversation_id_token = Phoenix.Token.sign(conn, "conversation_id", conversation_id)
        %{
          user_id_token: user_id_token,
          user_name: cs_rep.name || "Representative",
          channel_name: "conversation:#{conversation_id}",
          conversation_id_token: conversation_id_token
        }
    end

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(render_data))
  end

  def get_help(conn, %{"conversation_id_token" => conversation_id_token}) do
    user = Consult.hooks_module.user_for_request(conn)
    
    user_id_token = user_id_token(user.id)

    conversation_id = new_or_existing_conversation_id(conn, conversation_id_token)

    conversation_id_token = Phoenix.Token.sign(conn, "conversation_id", conversation_id)

    render_data = %{user_id_token: user_id_token, user_name: user.name || "User", channel_name: "conversation:#{conversation_id}", conversation_id_token: conversation_id_token}

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(render_data))
  end

  def close_conversation(conn, %{"conversation_id_token" => conversation_id_token}) do
    closed_conversation = with {:ok, conversation_id} <- Phoenix.Token.verify(
      conn, "conversation_id", conversation_id_token
    ), conversation <- Consult.repo.get_by(Conversation, id: conversation_id),
    %Conversation{} <- conversation do
      {:ok, conversation} = Conversation.end_now(conversation) |> Consult.repo.update
      conversation
    end

    render_data = %{ended_at: Ecto.DateTime.to_string(closed_conversation.ended_at)}

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(render_data))
  end

  defp new_or_existing_conversation_id(conn, convo_id_token) do
    with {:ok, convo_id} <- Phoenix.Token.verify(
      conn, "conversation_id", convo_id_token
    ), 
    %Conversation{} <- Consult.repo.get_by(Conversation, id: convo_id) do
      convo_id
    else
      _ ->
        new_conversation = Conversation.changeset(%Conversation{})
        {:ok, new_conversation} = Consult.repo.insert(new_conversation)
        new_conversation.id
    end 
  end

  defp user_id_token(user_id) do
    case user_id do
      nil -> nil
      _id  -> Phoenix.Token.sign(Consult.endpoint, "user_id", user_id)
    end
  end
end
