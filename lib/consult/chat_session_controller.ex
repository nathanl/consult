defmodule Consult.ChatSessionController do
  use Phoenix.Controller
  alias Consult.Conversation

  plug Consult.RepresentativesOnly when action in [:give_help]

  def give_help(conn, %{"conversation_id" => conversation_id}) do
    conversation = Consult.repo.get_by(Conversation, id: conversation_id)
    render_data = case conversation do
      nil -> %{error: "The requested conversation does not exist"}
      %Conversation{} ->
        chat_session_info(conn, "Representative", conversation_id)
    end

    send_json_response(conn, render_data)
  end

  def get_help(conn, %{"conversation_id_token" => conversation_id_token}) do
    conversation_id = Consult.ConversationSource.id_for(conversation_id_token)
    send_json_response(conn, chat_session_info(conn, "User", conversation_id))
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

  defp chat_session_info(conn, default_name, conversation_id) do
    user = Consult.hooks_module.user_for_request(conn)
    %{
      user_id_token: Consult.Token.sign_user_id(user.id),
      user_name: user.name || default_name,
      channel_name: "conversation:#{conversation_id}",
      conversation_id_token: Consult.Token.sign_conversation_id(conversation_id),
      user_public_identifier: Consult.Token.user_identifier(
        %{id: user.id, name: user.name || default_name}
      ),
    }
  end

end
