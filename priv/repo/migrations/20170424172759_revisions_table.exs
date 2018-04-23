defmodule RevisionairEcto.Repo.Migrations.RevisionsTable do
  use Ecto.Migration

  # Example migration for the revisions table, using numerical `item_id`s.
  def change do
    create table(:revisions) do
      add :item_type, :string, null: false
      add :item_id, :integer, null: false
      add :encoded_item, :binary, null: false
      add :metadata, :map, null: false
      add :revision, :integer, null: false
      add :struct_name, :string

      # For Postgrex, use `type: :timestamptz`
      timestamps([{:updated_at, false}, type: :timestamptz])
    end

    create index(:revisions, [:item_type, :item_id])
    create unique_index(:revisions, [:item_type, :item_id, :revision])
  end
end
