defmodule Consult.ChatSessionController do
  use Phoenix.Controller
  alias Consult.Conversation

  plug Consult.RepresentativesOnly when action in [:give_help, :watch_dashboard]

  def watch_dashboard(conn, %{}) do
    user = Consult.hooks_module.user_for_request(conn)
    send_json_response(conn, %{
      user_id_token: Consult.Token.sign_user_id(user.id),
      user_name: user.name,
    })
  end

  def give_help(conn, %{"conversation_id" => conversation_id}) do
    conversation = Consult.repo.get_by(Conversation, id: conversation_id)
    render_data = case conversation do
      nil -> %{error: "The requested conversation does not exist"}
      %Conversation{} ->
        chat_session_info(conn, "representative", conversation_id)
    end

    send_json_response(conn, render_data)
  end

  # TODO have separate function head for null vs not null token
  def get_help(conn, %{"conversation_id_token" => conversation_id_token}) do
    conversation_id = Consult.ConversationSource.id_for(conversation_id_token)
    send_json_response(
      conn, chat_session_info(conn, "user", conversation_id)
    )
  end

  defp send_json_response(conn, render_data) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(render_data))
  end

  defp chat_session_info(conn, user_role, conversation_id) do
    user = Consult.hooks_module.user_for_request(conn)
    user_name = user.name || default_user_name(user_role)
    user_id = user.id || default_user_id
    %{
      user_id_token: Consult.Token.sign_user_id(user_id),
      user_role_token: Consult.Token.sign_user_role(user_role),
      user_name: user_name,
      channel_name: "conversation:#{conversation_id}",
      conversation_id_token: Consult.Token.sign_conversation_id(conversation_id),
      user_public_identifier: Consult.Token.user_identifier(
        %{id: user_id, name: user_name}
      ),
    }
  end

  defp default_user_name(_role = "user"), do: "User"
  defp default_user_name(_role = "representative"), do: "Representative"
  defp default_user_id, do: "anonymous_id"

end
