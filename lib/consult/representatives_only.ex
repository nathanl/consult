defmodule Consult.RepresentativesOnly do
  @behaviour Plug
  import Plug.Conn

  def init(_opts) do
    :no_options
  end

  def call(conn, :no_options) do
    restrict_unless_is_representative(conn)
  end

  defp restrict_unless_is_representative(conn) do
    user = Consult.hooks_module().user_for_request(conn)

    if Consult.hooks_module().representative?(user) do
      conn
    else
      conn
      |> send_resp(403, "Not authorized")
      |> halt
    end
  end
end
