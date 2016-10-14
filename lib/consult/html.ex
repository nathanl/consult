defmodule Consult.Html do

  def static_path(conn, path) do
    # ERM this feels wrong
    conn.private.phoenix_endpoint.static_path(path)
  end

end
