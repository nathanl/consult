defmodule Consult.ConversationChannel do
  use Phoenix.Channel
  alias Consult.{Conversation,Message}
  require Ecto.Query

  def join("conversation:" <> requested_id, %{"conversation_id_token" => conversation_id_token, "user_id_token" => user_id_token, "user_role_token" => user_role_token, "user_name" => user_name}, socket) do
    authorized_id = Consult.Token.verify_conversation_id(conversation_id_token)
    [requested_id, authorized_id] = Enum.map([requested_id, authorized_id], &ensure_integer/1)
    
    if requested_id == authorized_id do
      authorized_role = Consult.Token.verify_user_role(user_role_token)
      verified_user_id = Consult.Token.verify_user_id(user_id_token)
      if authorized_role == "representative" do
        Conversation.if_unowned_mark_owned_by(authorized_id, verified_user_id)
      end
      send(self, {:after_join, authorized_id})
      socket = socket
      |> assign(:conversation_id, authorized_id)
      |> assign(:user_role, authorized_role)
      |> assign(:user_name, user_name)
      |> assign(:user_id, verified_user_id)
      {:ok, socket}
    else
      {:error, "Not authorized to join this conversation"}
    end
  end

  def handle_info({:after_join, conversation_id}, socket) do
    conversation = Consult.repo.one!(
      Ecto.Query.from c in Conversation, where: c.id == ^conversation_id, preload: [messages: (^Message.reverse_sequential(Message))]
      )
    conversation.messages |> :lists.reverse |> Enum.each(fn (message) ->
      push(socket, "new_msg", message_for_channel(message) )
    end)

    if Conversation.ended?(conversation) do
      push(socket, "conversation_closed", %{})
    end

    {:noreply, socket}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    %Conversation{ended_at: nil} = Consult.repo.get_by!(Conversation, id: socket.assigns[:conversation_id])
    message = record_message(socket.assigns[:conversation_id], body, socket.assigns[:user_id], socket.assigns[:user_name], socket.assigns[:user_role])

    broadcast!(socket, "new_msg", message_for_channel(message))
    Consult.PanelChannel.send_update
    {:noreply, socket}
  end

  def handle_in("conversation_closed", %{}, socket) do
    closed = close_conversation(socket.assigns[:conversation_id])
    body = [
      "(Conversation ended by",
      socket.assigns[:user_name],
      "at",
      Ecto.DateTime.to_string(closed.ended_at),
      ")",
    ] |> Enum.join(" ")

    sender_name = "System"
    message = record_message(socket.assigns[:conversation_id], body, socket.assigns[:user_id], sender_name, "system")

    broadcast!(socket, "new_msg", message_for_channel(message))
    broadcast!(socket, "conversation_closed", %{})
    Consult.PanelChannel.send_update
    {:noreply, socket}
  end

  defp record_message(conversation_id, content, sender_id, sender_name, sender_role) do
    new_message =
      %Message{content: content, conversation_id: conversation_id, sender_name: sender_name, sender_id: sender_id, sender_role: sender_role}
      |> Message.changeset
      {:ok, message} = Consult.repo.insert(new_message)
      message
  end

  defp close_conversation(convo_id) do
    with conversation <- Consult.repo.get_by(Conversation, id: convo_id),
    %Conversation{} <- conversation do
      {:ok, conversation} = (Conversation.end_now(conversation) |> Consult.repo.update)
      conversation
    end
  end

  defp ensure_integer(n) when is_integer(n), do: n
  defp ensure_integer(n) when is_binary(n) do
     case Integer.parse(n) do
       {intpart, _nonintpart} -> intpart
       _ -> raise "invalid integer"
     end
  end

  defp message_for_channel(message) do
    %{
      timestamp: Ecto.DateTime.to_string(message.inserted_at),
      from: message.sender_name,
      # We don't use the user_id or user_id_token for security reasons;
      # we don't want the receiver to be able to impersonate the sender
      user_public_identifier: Consult.Token.user_identifier(
        %{id: message.sender_id, name: message.sender_name}
      ),
      body: message.content,
    }
  end


end
