defmodule Consult.ChannelTest do
  use ChannelCase

  setup do
    {:ok, _, socket} = socket() |> subscribe_and_join(Consult.PanelChannel, "cs_panel")
    {:ok, socket: socket}
  end

  test "sends an updated CS panel" do
    TestApp.Repo.insert!(Fixtures.ongoing_conversation)
    Consult.PanelChannel.send_update
    assert_broadcast "update", %{main_contents: main_contents}
    assert Regex.match?(~r/\<h1\>Conversations\<\/h1\>/, main_contents)
    assert Regex.match?(~r/\<div class="conversation"\>/, main_contents)
  end

end
