defmodule Consult.Authorized do
  @behaviour Plug
  import Plug.Conn

  def init(_opts) do
    :no_options
  end

  def call(conn, :no_options) do
    is_authorized?(conn)
  end

  defp is_authorized?(conn) do
    user = Consult.hooks.user_for_session(conn)
    if Consult.hooks.representative?(user) do
      conn 
    else
      conn
      |> send_resp(403, "Not authorized")
      |> halt
    end
  end

end
