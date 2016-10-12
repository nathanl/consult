defmodule Consult.PanelChannel do
  use Phoenix.Channel

  def join("panel_updates", _opts, socket) do
    {:ok, socket}
  end

  def send_update do
    Consult.Hooks.endpoint.broadcast(
      "panel_updates",
      "update",
      %{body: Consult.ConversationSummary.html}
    )
  end
end
