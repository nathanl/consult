defmodule PanelChannel do
  use Phoenix.Channel

  def join("panel_updates", _opts, socket) do
    {:ok, socket}
  end

  def send_update do
    Consult.Hooks.endpoint.broadcast(
    # TODO - have this render something meaningful
    "panel_updates", "update", %{body: "<h1>CS Panel</h1>"}
    )
  end
end
