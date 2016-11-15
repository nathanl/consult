defmodule TestApp.Presence do
  use Phoenix.Presence, otp_app: :consult, pubsub_server: Consult.PubSub
end
