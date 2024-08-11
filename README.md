# Zephyr

**Elixir authorization system based on the ReBAC (Relationship-based Access Control) model**

Zephyr is an authorization library based on [Google's Zanzibar](https://research.google/pubs/zanzibar-googles-consistent-global-authorization-system/). Zephyr though based on Zanzibar, its
semantics for defining objects and access control closely follows [Authzed's SpiceDB](https://authzed.com/spicedb).

To know more about how ReBAC authorization works, click on the Zanzibar and SpiceDB links above.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `zephyr` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:zephyr, "~> 1.0.0-alpha.1"}
  ]
end
```

## Usage

1. Generate a migration for relation tuples. You may use `mix ecto.gen.migration create_relations`.
   You may choose any filename you want.

```elixir
defmodule MyApp.Repo.Migrations.CreateRelations do
  use Ecto.Migration


  def up, do: Zephyr.Migrations.up(subject_key_type: :integer, object_key_type: :integer)
  def down, do: Zephyr.Migrations.down()
end

```

2. Add your objects. You may write the objects on any filename and path as long as they're
   included in the compilation and `Zephyr.Definition`is imported. For example, `lib/my_app/definitions.ex`:

```elixir
import Zephyr.Definition

# Defines an object called users
definition(:users)

# Defines an object called organizations
definition :organizations do
  # Member of organizations are user objects
  relation(:member, :users)
end

# Defines an object called repositories
definition :repositories do
  # Maintainer of repositories are user objects
  relation(:maintainer, :users)
  # Parent of repository is an organization
  relation(:parent_org, :organizations)
  # Repositories can be read by maintainers or member of the parent organization
  relation(:reader, :maintainer + (:parent_org > :member))
end

# Defines an object called issues
definition :issues do
  # Users are creator of issues
  relation(:creator, :users)
  # Issues are under a parent repository
  relation(:parent_repository, :repositories)
  # Creators and reader of the parent repository can close issues
  relation(:closer, :creator + (:parent_repository > :reader))
end
```

Objects should always refer to tables of the resources in your application.

3. You should now be able to write relations in your app via the `write/2` API. For example:

```elixir
# For example below are users, an issue, and its parent org retrieved from the database
alice = %MyApp.User{id: 1}
bob = %MyApp.User{id: 2}
repository = %MyApp.Repository{id: 3}
issue = %MyApp.Issue{id: 4}

# The two arguments in the write/2 API refers to subject and object, respectively.

# They can be read as follows:
# User with id 1 (the subject) is the creator (object predicate) of Issue with id 4
{:ok, auth} = Zephyr.write({"users", alice.id, nil}, {"issues", issue.id, "creator"})

# User with id 2 is a maintainer of Repository with id 3
{:ok, auth} = Zephyr.write({"users", bob.id, nil}, {"repositories", org.id, "maintainer"})

# Repository with id 3 is the parent repository of Issue with id 4
{:ok, auth} = Zephyr.write({"repositories", repository.id, nil}, {"issues", issue.id, "parent_repository"})
```

4. As seen in the issues definition above
   > Creators and reader of the parent repository can close issues

This means Alice and Bob should have a relation `closer` to issue because Alice created it and Bob is a maintainer of the issue's parent repository. To check we can use the
`check/3` API:

```elixir
iex> Zephyr.check(issue, "closer", alice)
true

iex> Zephyr.check(issue, "closer", bob)
true

iex> Zephyr.check(issue, "closer", user_neither_creator_nor_maintainer)
false
```

## Operators

There are 4 supported operators to define policies:

1. Union (+)
   Unions are read as "or". For example `relation(:commenter, :editor + :reader)` means
   an object with this policy has relation `commenter` if subject has relation `editor` or `reader`
   to the object.

2. Exclusion (-)
   Excludes the righthand result from the lefthand sets of subjects. For example `relation(:commenter, :editor - :reader)` means if Alice has relation editor and reader, Bob has editor relation only, and
   Charlie has reader relation only. Then Alice and Charlie will be excluded and Bob will only have the access.

3. Intersection (&&)
   Intersections are read as "and". For example `relation(:commenter, :editor && :reader)` means
   an object with this policy has relation `commenter`if subject has both relation `editor` and `reader`.

4. Walk (>)
   This traverses the relation from the object itself to another object as seen in the example
   `relation(:closer, :creator + (:parent_repository > :reader))`. Always wrap them in parenthesis.

## `:_this` object

`:_this` refers to direct relations. For example `relation(:editor, :_this + (:parent > :maintainer))`
is similar to `relation(:editor, :editor + (:parent > :maintainer))`

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/zephyr>.
