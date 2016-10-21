defmodule Fixtures do
  alias Consult.{Conversation,Message,Tag}

  def new_conversation do
    %Conversation{}
  end

  def conversation_with_tags(tag_names) do
    %Conversation {
      tags: Enum.map(tag_names, fn (tag_name) ->
        %Tag{name: tag_name}
      end),
      messages: [
        %Message{
          sender_id: nil,
          sender_name: "User",
          sender_role: "user",
          content: "How much you want for that hamburger menu?",
        },
      ]
    }
  end

  def ongoing_conversation(options \\ %{rep_id: "1"}) do
    %Conversation {
      messages: [
        %Message{
          sender_id: nil,
          sender_name: "User",
          sender_role: "user",
          content: "Is your maple syrup vegan?"
        },
        %Message{
          sender_id: options.rep_id,
          sender_role: "representative",
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
          sender_role: "user",
          content: "Hello, I would like to buy a fish license, please."
        },
        %Message{
          sender_id: nil,
          sender_name: "Cleese",
          sender_role: "user",
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
          sender_role: "user",
          content: "How quickly can you ship a fire extinguisher?"
        },
        %Message{
          sender_id: "rep@example.com",
          sender_name: "Rep",
          sender_role: "representative",
          content: "Could be there by Tuesday."
        },
        %Message{
          sender_id: nil,
          sender_name: "Alex",
          sender_role: "user",
          content: "OK. That's [cough] probably fine, thanks!"
        },
      ]
    }
  end

end
