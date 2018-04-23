# To test normal, numerical IDs.
defmodule Post do
  use Ecto.Schema

  schema "posts" do
    field :title, :string
    field :content, :string
  end
end
