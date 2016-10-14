defmodule TestApp.Repo.Migrations.AddConversationsMessagesAndTags do
  use Ecto.Migration

  def change do
    create table(:consult_conversations) do
      add :ended_at, :datetime
      timestamps
    end

    create table(:consult_messages) do
      add :conversation_id, references(:consult_conversations)
      add :content, :text, null: false
      add :sender_name, :string, null: false
      add :sender_id, :string

      timestamps
    end

    create table(:consult_tags) do
      add :name, :string, size: 64
    end

    create table(:consult_conversations_tags) do
      add :conversation_id, references(:consult_conversations)
      add :tag_id, references(:consult_tags)

      timestamps
    end
  end
end
