defmodule Consult.ConversationView do
  use Phoenix.View, root: "web/templates"
  # Import convenience functions from controllers
  import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]
  # Use all HTML functionality (forms, tags, etc)
  use Phoenix.HTML
end
