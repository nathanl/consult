defmodule Consult.ChannelTest do
  use ChannelCase

  setup do
    {:ok, _, socket} = socket() |> subscribe_and_join(Consult.PanelChannel, "panel_updates")
    {:ok, socket: socket}
  end

  test "sends an updated CS panel" do
    Fixtures.insert_conversations
    Consult.PanelChannel.send_update
    assert_broadcast "update", %{body: panel_body}
    assert Regex.match?(~r/\<h1\>Conversations\<\/h1\>/, panel_body)
    assert Regex.match?(~r/\<div class="conversation"\>/, panel_body)
  end

end
