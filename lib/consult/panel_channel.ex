defmodule Consult.PanelChannel do
  use Phoenix.Channel

  def join("panel_updates", _opts, socket) do
    {:ok, socket}
  end

  def the_endpoint do
    Application.get_env(:consult, :endpoint)
  end

  def send_update do
    apply(Application.get_env(:consult, :endpoint), :broadcast,
      [
      "panel_updates",
      "update",
      %{body: Consult.ConversationSummary.html}
      ]
    )
  end
end
