defmodule RevisionairEcto.Revision do
  use Ecto.Schema

  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime]
  schema "revisions" do
    field(:item_type, :string)
    field(:item_id, :integer)
    field(:encoded_item, :binary)
    field(:metadata, :map)
    field(:revision, :integer)
    field(:struct_name, :string)

    timestamps([{:updated_at, false}])
  end

  @required_fields ~w(item_type item_id encoded_item revision)a
  @optional_fields ~w(meta struct_name)a

  def changeset(struct, attrs \\ :empty) do
    struct
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
