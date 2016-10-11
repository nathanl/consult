defmodule ChannelCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Phoenix.ChannelTest
      @endpoint TestApp.Endpoint
    end
  end
end
