defmodule Consult.Html do
  def static_path(conn, path) do
    # TODO this feels wrong - can we get it from host app?
    conn.private.phoenix_endpoint.static_path(path)
  end
end
