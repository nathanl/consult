defmodule Consult.Tag do
  use Ecto.Schema
  import Ecto
  import Ecto.Changeset
  import Ecto.Query

  schema "consult_tags" do
    field :name, :string
  end

end
