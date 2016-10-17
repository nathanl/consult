defmodule Consult.ConversationSource do
  alias Consult.Conversation

  def id_for(convo_id_token) when convo_id_token == "null" do
    new_conversation_id
  end

  def id_for(convo_id_token) do
    with convo_id <- Consult.Token.verify_conversation_id(convo_id_token),
    %Conversation{} <- Consult.repo.get_by(Conversation, id: convo_id) do
      convo_id
    else
      _ ->
        new_conversation_id
    end
  end

  defp new_conversation_id do
    new_conversation = Conversation.changeset(%Conversation{})
    {:ok, new_conversation} = Consult.repo.insert(new_conversation)
    new_conversation.id
  end

end
