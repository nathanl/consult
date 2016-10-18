defmodule Consult.Tag do
  use Ecto.Schema
  alias Consult.Tag

  schema "consult_tags" do
    field :name, :string
  end

  def options do
    Consult.repo.all(Tag) |> Enum.map(fn(tag) -> {tag.name, tag.id} end)
  end

end
