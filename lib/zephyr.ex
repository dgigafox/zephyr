defmodule Zephyr do
  @moduledoc """
  Documentation for `Zephyr`.
  """
  alias Ecto.Changeset.Relation
  alias Zephyr.Helpers
  alias Zephyr.QueryBuilder
  alias Zephyr.RelationResolver
  alias Zephyr.RelationTuple

  @type relation_tuple :: {namespace :: String.t(), key :: any(), predicate :: String.t()}

  @doc """
  Checks if the given subject has access to the given object based on the given relation
  """
  @spec check(
          object :: Ecto.Schema.t(),
          relation :: String.t(),
          subject :: Ecto.Schema.t(),
          opts :: Keyword.t()
        ) ::
          boolean()
  def check(object, relation, subject, repo_opts \\ []) do
    object_source = object.__struct__.__schema__(:source)
    subject_source = subject.__struct__.__schema__(:source)
    {repo, repo_opts} = fetch_repo_opts(repo_opts)

    object_source
    |> Helpers.get_definition()
    |> RelationResolver.resolve_relation(String.to_atom(relation))
    |> QueryBuilder.build_query(object)
    |> repo.all(repo_opts)
    |> Enum.map(&{&1.subject_namespace, &1.subject_key})
    |> Enum.member?({subject_source, subject.id})
  end

  @doc """
  Inserts a new relation between the given subject and object
  """
  @spec write(subject :: relation_tuple(), object :: relation_tuple()) ::
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
  @spec write!(subject :: relation_tuple(), object :: relation_tuple()) :: Relation.t()
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
