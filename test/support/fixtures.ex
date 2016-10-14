defmodule Fixtures do
  alias Consult.{Conversation,Message}

  def ongoing_conversation(options \\ %{rep_id: "1"}) do
    %Conversation {
      messages: [
        %Message{
          sender_id: nil,
          sender_name: "User",
          content: "Is your maple syrup vegan?"
        },
        %Message{
          sender_id: options.rep_id,
          sender_name: "Rep",
          content: "Yes, and made from free-range trees!"
        },
      ]
    }
  end

  def unanswered_conversation do
    %Conversation {
      messages: [
        %Message{
          sender_id: nil,
          sender_name: "Cleese",
          content: "Hello, I would like to buy a fish license, please."
        },
        %Message{
          sender_id: nil,
          sender_name: "Cleese",
          content: "He is an halibut."
        },
      ]
    }
  end

  def ended_conversation do
    %Conversation {
      ended_at: Ecto.DateTime.utc,
      messages: [
        %Message{
          sender_id: nil,
          sender_name: "Alex",
          content: "How quickly can you ship a fire extinguisher?"
        },
        %Message{
          sender_id: "rep@example.com",
          sender_name: "Rep",
          content: "Could be there by Tuesday."
        },
        %Message{
          sender_id: nil,
          sender_name: "Alex",
          content: "OK. That's [cough] probably fine, thanks!"
        },
      ]
    }
  end

end
