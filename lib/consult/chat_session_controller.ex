defmodule Consult.ChatSessionController do
  use Phoenix.Controller
  alias Consult.Conversation

  plug Consult.RepresentativesOnly when action in [:give_help]

  def give_help(conn, %{"conversation_id" => conversation_id}) do
    conversation = Consult.repo.get_by(Conversation, id: conversation_id)
    render_data = case conversation do
      nil -> %{error: "The requested conversation does not exist"}
      %Conversation{} ->
        cs_rep = Consult.hooks_module.user_for_request(conn)
        user_id_token = Consult.Token.sign_user_id(cs_rep.id)
        conversation_id_token = Consult.Token.sign_conversation_id(conversation_id)
        %{
          user_id_token: user_id_token,
          user_name: cs_rep.name || "Representative",
          channel_name: "conversation:#{conversation_id}",
          conversation_id_token: conversation_id_token
        }
    end

    send_json_response(conn, render_data)
  end

  def get_help(conn, %{"conversation_id_token" => conversation_id_token}) do
    user = Consult.hooks_module.user_for_request(conn)
    
    user_id_token = Consult.Token.sign_user_id(user.id)

    conversation_id = Consult.ConversationSource.id_for(conversation_id_token)

    conversation_id_token = Consult.Token.sign_conversation_id(conversation_id)

    render_data = %{user_id_token: user_id_token, user_name: user.name || "User", channel_name: "conversation:#{conversation_id}", conversation_id_token: conversation_id_token}

    send_json_response(conn, render_data)
  end

  def close_conversation(conn, %{"conversation_id_token" => conversation_id_token}) do
    closed_conversation = with convo_id <- Consult.Token.verify_conversation_id(conversation_id_token),
    conversation <- Consult.repo.get_by(Conversation, id: convo_id),
    %Conversation{} <- conversation do
      {:ok, conversation} = Conversation.end_now(conversation) |> Consult.repo.update
      conversation
    end

    render_data = %{ended_at: Ecto.DateTime.to_string(closed_conversation.ended_at)}

    send_json_response(conn, render_data)
  end

  defp send_json_response(conn, render_data) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(render_data))
  end

end
