defmodule RevisionairEctoTest do
  use ExUnit.Case, async: true
  doctest RevisionairEcto

  alias RevisionairEcto.Repo


  defmodule TestStruct do
    defstruct id: 0, foo: 1, bar: 2
  end

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end


  test "Simple flow using test RevisionairEcto" do
    f1 = %TestStruct{id: 1, foo: 0}
    f1b = %TestStruct{f1 | foo: 2, bar: 3}

    {:ok, {revision1, %{revision: 0, inserted_at: _}}} = Revisionair.store_revision(f1, [storage: RevisionairEcto])
    assert revision1 == f1

    {:ok, {revision2, %{revision: 1, inserted_at: _}}} = Revisionair.store_revision(f1b, [storage: RevisionairEcto])
    assert revision2 == f1b

    [{^f1b, %{revision: 1, inserted_at: _}}, {^f1, %{revision: 0, inserted_at: _}}] = Revisionair.list_revisions(f1b, [storage: RevisionairEcto])

    assert Revisionair.delete_all_revisions_of(f1b, [storage: RevisionairEcto]) == {2, nil}
    assert Revisionair.list_revisions(f1b, [storage: RevisionairEcto]) == []
    assert Revisionair.list_revisions(f1, [storage: RevisionairEcto]) == []

  end

  test "explicit structure_type and unique_identifier using RevisionairEcto" do
    f1 = %TestStruct{id: 1, foo: 0}
    f1b = %TestStruct{f1 | foo: 2, bar: 3}

    {:ok, {revision1, %{revision: 0, inserted_at: _}}} = Revisionair.store_revision(f1, TestStruct, 1, [storage: RevisionairEcto])
    {:ok, {revision2, %{revision: 1, inserted_at: _}}} = Revisionair.store_revision(f1b, [storage: RevisionairEcto])

    assert revision1 == f1
    assert revision2 == f1b

    [{^f1b, %{revision: 1, inserted_at: _}}, {^f1, %{revision: 0, inserted_at: _}}] = Revisionair.list_revisions(TestStruct, 1, [storage: RevisionairEcto])

  end

  test "get_revision using RevisionairEcto" do
    f1 = %TestStruct{id: 1, foo: 0}
    f1b = %TestStruct{f1 | foo: 2, bar: 3}

    {:ok, {revision1, %{revision: 0, inserted_at: _}}} = Revisionair.store_revision(f1, [storage: RevisionairEcto])
    {:ok, {revision2, %{revision: 1, inserted_at: _}}} = Revisionair.store_revision(f1b, [storage: RevisionairEcto])

    assert revision1 == f1
    assert revision2 == f1b

    {:ok, {r, %{revision: 1, inserted_at: _}}} = Revisionair.get_revision(f1b, 1, [storage: RevisionairEcto])
    assert r == f1b

    {:ok, {r, %{revision: 0, inserted_at: _}}} = Revisionair.get_revision(f1b, 0, [storage: RevisionairEcto])
    assert r == f1
  end

  test "normal ID integration" do
    {:ok, post} = Repo.transaction fn ->
      post = Repo.insert!(%Post{title: "Test", content: "Lorem ipsum"})
      {:ok, _revision} = Revisionair.store_revision(post, Post, post.id)
      post
    end

    assert Repo.all(Post) != []
    {:ok, {^post, %{revision: 0}}} = Revisionair.get_revision(post, 0)
    {:ok, {^post, %{revision: 0}}} = Revisionair.newest_revision(post)
    [{^post, %{revision: 0, inserted_at: _}}] = Revisionair.list_revisions(post)
    assert Revisionair.delete_all_revisions_of(post) == {1, nil}
    assert Revisionair.list_revisions(post) == []
  end

end
