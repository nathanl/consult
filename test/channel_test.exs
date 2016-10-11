defmodule Consult.ChannelTest do
  use ChannelCase

  defmodule Consult.Hooks do
    def endpoint do
      TestApp.Endpoint
    end
  end

  defmodule PanelChannel do
    use Phoenix.Channel

    def join("panel_updates", _opts, socket) do
      {:ok, socket}
    end

    def send_update do
      Consult.Hooks.endpoint.broadcast(
        # TODO - have this render something meaningful
        "panel_updates", "update", %{body: "<h1>The Panel</h1>"}
      )
    end
  end

  setup do
    {:ok, _, socket} = socket() |> subscribe_and_join(PanelChannel, "panel_updates")
    {:ok, socket: socket}
  end

  test "sends an updated CS panel" do
    PanelChannel.send_update
    assert_broadcast "update", %{body: "<h1>The Panel</h1>"}
  end

end
