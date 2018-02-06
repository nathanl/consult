defmodule Consult.PanelChannel do
  use Phoenix.Channel

  def join("cs_panel:" <> user_id_token, %{"name" => user_name}, socket) do
    send(self, :after_join)

    socket =
      socket
      |> assign(:user_token, user_id_token)
      |> assign(:user_name, user_name)

    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    {:ok, _} =
      Consult.presence_module().track(self, "cs_panel", socket.assigns.user_token, %{
        name: socket.assigns.user_name,
        online_at: inspect(System.system_time(:seconds))
      })

    # TODO - display presence info client-side
    push(socket, "presence_state", presence_list)
    {:noreply, socket}
  end

  def send_update do
    Enum.each(presence_list, fn {user_id_token, _} ->
      user_id = Consult.Token.verify_user_id(user_id_token)
      html = Consult.ConversationSummary.html(user_id)
      Consult.endpoint().broadcast("cs_panel:#{user_id_token}", "update", %{main_contents: html})
    end)
  end

  defp presence_list do
    Phoenix.Presence.list(Consult.presence_module(), "cs_panel")
  end
end
