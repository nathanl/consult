defmodule Consult.ChannelTest do
  use ChannelCase

  defmodule OurChannel do
    use Phoenix.Channel

    def join("some:topic", _opts, socket) do
      {:ok, socket}
    end

    def handle_in("ping", payload, socket) do
      {:reply, {:ok, payload}, socket}
    end
  end

  setup do
    {:ok, _, socket} = socket() |> subscribe_and_join(OurChannel, "some:topic")
    {:ok, socket: socket}
  end

  test "ping replies with status :ok", %{socket: socket} do
    ref = push socket, "ping", %{"hello" => "there"}
    assert_reply ref, :ok, %{"hello" => "there"}
  end

end
