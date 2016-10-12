defmodule Consult.ChannelTest do
  use ChannelCase

  setup do
    {:ok, _, socket} = socket() |> subscribe_and_join(PanelChannel, "panel_updates")
    {:ok, socket: socket}
  end

  test "sends an updated CS panel" do
    PanelChannel.send_update
    assert_broadcast "update", %{body: panel_body}
    assert Regex.match?(~r/\<h1\>CS Panel\<\/h1\>/, panel_body)
  end

end
