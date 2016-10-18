defmodule Consult.ConversationView do
  use Phoenix.View, root: "web/templates"
  # Import convenience functions from controllers
  import Phoenix.Controller, only: [get_flash: 2]
  # Use all HTML functionality (forms, tags, etc)
  use Phoenix.HTML
end
