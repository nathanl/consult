defmodule Consult.PanelChannel do
  use Phoenix.Channel

  def join("panel_updates", _opts, socket) do
    {:ok, socket}
  end

  def send_update do
    {:safe, html_iodata} = Phoenix.View.render(
      Consult.ConversationView, "index.html", conversations: collection_for_cs_panel
    )
    html_string = :erlang.iolist_to_binary(html_iodata)
    Consult.Hooks.endpoint.broadcast(
    "panel_updates", "update", %{body: html_string}
    )
  end

  def collection_for_cs_panel do
    [
      {"Unanswered", []},
      {"Ongoing", []},
      {"Ended", []},
    ]
  end

end
