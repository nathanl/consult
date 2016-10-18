defmodule Consult.ConversationController do
  use Phoenix.Controller
  import Ecto.Query

  alias Consult.{Conversation,Tag,ConversationTag}

  plug Consult.RepresentativesOnly

  def index(conn, _assigns) do
    conversations = Consult.ConversationSummary.conversations
    render conn, conversations: conversations, layout: {Consult.ConversationView, "layout.html"}
  end

  def show(conn, %{"id" => conversation_id}) do
    conversation = conversation_with_tags(conversation_id)
    render(conn, "show.html", %{
      id: conversation_id,
      layout: {Consult.ConversationView, "layout.html"},
      ended: Conversation.ended?(conversation),
      possible_tags: Tag.options,
      current_tag_ids: (conversation.conversation_tags |> Enum.map(&(&1.tag_id))),
    })
  end

  def set_tags(conn, %{"tag_ids" => tag_ids, "id" => conversation_id}) do
    conversation = conversation_with_tags(conversation_id)
    existing_taggings = conversation.conversation_tags
    {:ok, to_delete, to_insert} = ConversationTag.updates_for(
      existing_taggings, conversation_id, checked_values_from(tag_ids)
    )

    to_insert = to_insert |> (Enum.map(fn (ct) ->
      ConversationTag.changeset(
        %ConversationTag{},
        %{
          tag_id: ct.tag_id,
          conversation_id: ct.conversation_id,
        }
        )
    end))

    multi = to_delete |> Enum.reduce(Ecto.Multi.new, fn (record, multi_acc) ->
      Ecto.Multi.delete(multi_acc, "delete_#{record.id}", record)
    end)
    multi = to_insert |> Enum.reduce(multi, fn (changeset, multi_acc) ->
      # TODO make this less horrible and hacky!
      Ecto.Multi.insert(multi_acc, "insert_#{:rand.uniform(1_000)}", changeset)
    end)
    Consult.repo.transaction(multi)

    Consult.PanelChannel.send_update

    # TODO ask about and maybe do a PR on Phoenix to add this?
    # see https://github.com/phoenixframework/phoenix/pull/1402
    redirect conn, to: local_referer(conn)
  end

  defp conversation_with_tags(conversation_id) do
    query = from c in Conversation, where: c.id == ^conversation_id
    Consult.repo.one!(Conversation.Scopes.with_conversation_tags(query))
  end

  defp checked_values_from(checkbox_params) do
    checkbox_params |>
    Enum.reduce([], fn ({k, v}, acc) ->
    if v == "true", do: [k | acc], else: acc
    end)
  end

  def referer(conn) do
    case List.keyfind(conn.req_headers, "referer", 0) do
      {"referer", referer} -> referer
      nil                  -> raise "no referer"
    end
  end

  def local_referer(conn) do
    referer_url  = referer(conn)
    referer_host = URI.parse(referer_url).host
    if referer_host == conn.host do
      URI.parse(referer_url).path
    else
      raise "not a local path"
    end
  end
      
end
