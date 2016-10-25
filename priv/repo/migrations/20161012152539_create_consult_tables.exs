defmodule TestApp.Repo.Migrations.CreateConsultTables do
  use Ecto.Migration

  def change do
    create table(:consult_conversations) do
      add :ended_at, :datetime
      add :owned_by_id, :string
      timestamps
    end

    create table(:consult_messages) do
      add :conversation_id, references(:consult_conversations)
      add :content, :text, null: false
      add :sender_name, :string, null: false
      add :sender_id, :string
      add :sender_role, :string, null: false

      timestamps
    end
    create index(:consult_messages, [:conversation_id])

    create table(:consult_tags) do
      add :name, :string, size: 64
    end

    create table(:consult_notes) do
      add :conversation_id, references(:consult_conversations)
      add :content, :text, null: false
      add :author_name, :string, null: false
      add :author_id, :string
    end
    create index(:consult_notes, [:conversation_id])

    create table(:consult_conversations_tags) do
      add :conversation_id, references(:consult_conversations)
      add :tag_id, references(:consult_tags)

      timestamps
    end
    create index(:consult_conversations_tags, [:conversation_id])
    create index(:consult_conversations_tags, [:tag_id])
    create unique_index(
      :consult_conversations_tags, [:conversation_id, :tag_id]
    )
  end
end
