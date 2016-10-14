defmodule Consult.PanelChannel do
  use Phoenix.Channel

  def join("cs_panel", _opts, socket) do
    {:ok, socket}
  end

  def send_update do
    Consult.endpoint.broadcast(
      "cs_panel",
      "update",
      %{main_contents: Consult.ConversationSummary.html}
    )
  end
end
