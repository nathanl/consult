defmodule Fixtures do
  alias Consult.{Conversation,Message}

  def ongoing_conversation do
    %Conversation {
      messages: [
        %Message{
          sender_id: nil,
          sender_name: "User",
          content: "Is your maple syrup vegan?"
        },
        %Message{
          sender_id: 1,
          sender_name: "Rep",
          content: "Yes, and made from free-range trees!"
        },
      ]
    }
  end

end
