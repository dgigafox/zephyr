defmodule Zephyr do
  @moduledoc """
  Documentation for `Zephyr`.
  """
  alias Ecto.Changeset.Relation
  alias Zephyr.Helpers
  alias Zephyr.QueryBuilder
  alias Zephyr.RelationResolver
  alias Zephyr.RelationTuple

  @type userset :: {namespace :: String.t(), object_id :: any(), relation :: String.t()}

  @doc """
  List relation tuples who has relation to the object. Depends only on the contents
  of the relation tuples and do not reflect the defined rules.
  """
  @spec read(
          object :: Ecto.Schema.t(),
          relation :: String.t(),
          repo_opts :: Keyword.t()
        ) :: [RelationTuple.t()]
  def read(object, relation, repo_opts \\ []) do
    {repo, repo_opts} = fetch_repo_opts(repo_opts)

    object
    |> QueryBuilder.read_query(relation)
    |> repo.all(repo_opts)
  end

  @doc """
  Returns the effective userset given an object and relation. Unlike `read/3`, this follows
  the defined rules.
  """
  @spec extend(
          object :: Ecto.Schema.t(),
          relation :: String.t(),
          repo_opts :: Keyword.t()
        ) :: [userset()]
  def extend(object, relation, repo_opts \\ []) do
    object_source = Ecto.get_meta(object, :source)
    {repo, repo_opts} = fetch_repo_opts(repo_opts)

    object_source
    |> Helpers.get_definition()
    |> RelationResolver.run(String.to_atom(relation))
    |> QueryBuilder.build_query(object)
    |> repo.all(repo_opts)
    |> Enum.map(&{&1.subject_namespace, &1.subject_key, &1.subject_predicate})
  end

  @doc """
  Checks if the given subject has access to the given object based on the given relation
  """
  @spec check(
          object :: Ecto.Schema.t(),
          relation :: String.t(),
          subject :: Ecto.Schema.t(),
          repo_opts :: Keyword.t()
        ) ::
          boolean()
  def check(object, relation, subject, repo_opts \\ []) do
    object_source = Ecto.get_meta(object, :source)
    subject_source = Ecto.get_meta(subject, :source)
    {repo, repo_opts} = fetch_repo_opts(repo_opts)

    object_source
    |> Helpers.get_definition()
    |> RelationResolver.run(String.to_atom(relation))
    |> QueryBuilder.build_query(object)
    |> repo.all(repo_opts)
    |> Enum.map(&{&1.subject_namespace, &1.subject_key})
    |> Enum.member?({subject_source, subject.id})
  end

  @doc """
  Inserts a new relation between the given subject and object
  """
  @spec write(
          subject :: userset(),
          object :: userset(),
          repo_opts :: Keyword.t()
        ) ::
          {:ok, Relation.t()} | {:error, Ecto.Changeset.t()}
  def write(subject, object, repo_opts \\ []) do
    {repo, repo_opts} = fetch_repo_opts(repo_opts)

    subject
    |> change_relation_tuple(object)
    |> repo.insert(repo_opts)
  end

  @doc """
  Similar to write/2 but raises an error if the relation could not be inserted
  """
  @spec write!(
          subject :: userset(),
          object :: userset(),
          repo_opts :: Keyword.t()
        ) ::
          Relation.t()
  def write!(subject, object, repo_opts \\ []) do
    {repo, repo_opts} = fetch_repo_opts(repo_opts)

    subject
    |> change_relation_tuple(object)
    |> repo.insert!(repo_opts)
  end

  defp change_relation_tuple(
         {subject_namespace, subject_key, subject_predicate},
         {object_namespace, object_key, object_predicate}
       ) do
    %RelationTuple{}
    |> RelationTuple.changeset(%{
      subject_namespace: subject_namespace,
      subject_key: subject_key,
      subject_predicate: subject_predicate,
      object_namespace: object_namespace,
      object_key: object_key,
      object_predicate: object_predicate
    })
  end

  defp fetch_repo_opts(opts) do
    {opts[:repo] || repo!(), Keyword.take(opts, [:prefix])}
  end

  defp repo! do
    Application.get_env(:zephyr, :repo) || raise "Repo not configured"
  end
end
