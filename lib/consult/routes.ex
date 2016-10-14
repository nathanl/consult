defmodule Consult.Routes do
  use Phoenix.Router

  scope "/", Consult do
    pipeline :consult_browser do
      plug :accepts, ["html"]
      plug :fetch_session
      plug :fetch_flash
      plug :protect_from_forgery
      plug :put_secure_browser_headers
    end

    pipeline :consult_api do
      plug :accepts, ["json"]
    end

    scope "/" do
      pipe_through :consult_browser
      get "/conversations/:id", ConversationController, :show
      get "/conversations",    ConversationController, :index
      post "/set_tags/:id",    ConversationController, :set_tags
    end

    scope "/api" do
      pipe_through :consult_api
      get  "/get_help",                        ChatSessionController, :get_help
      get  "/give_help/:conversation_id",      ChatSessionController, :give_help
      put  "/close_conversation/:conversation_id_token", ChatSessionController, :close_conversation
    end
  end
end
