defmodule Zephyr.QueryBuilder do
  @moduledoc """
  Traverse the resolved relations and build the query.
  """
  import Ecto.Query
  alias Zephyr.RelationTuple

  def read_query(object, relation) do
    {initial_query, cte_name} =
      case object do
        %Ecto.Query{from: %{source: {table, _}}} = query ->
          query = exclude(query, :select)

          query =
            RelationTuple
            |> where([r], r.object_key in subquery(query |> select([:subject_key])))
            |> where([r], r.object_namespace in subquery(query |> select([:subject_namespace])))
            |> where(object_predicate: ^relation)

          {query, "#{table}_#{relation}"}

        object ->
          source = object.__struct__.__schema__(:source)

          query =
            RelationTuple
            |> where(object_key: ^object.id)
            |> where(object_namespace: ^source)
            |> where(object_predicate: ^relation)

          {query, "#{object.table}_#{relation}"}
      end

    recursion_query =
      RelationTuple
      |> join(:inner, [r], cte in ^cte_name,
        on:
          cte.subject_key == r.object_key and
            cte.subject_namespace == r.object_namespace and
            cte.subject_predicate == r.object_predicate
      )

    read_query = union_all(initial_query, ^recursion_query)

    {cte_name, RelationTuple}
    |> recursive_ctes(true)
    |> with_cte(^cte_name, as: ^read_query)
    |> select([:subject_key, :subject_namespace, :subject_predicate])
  end

  def build_query(relations, object) do
    do_build_query(object, relations)
  end

  defp do_build_query(object, {:+, [relation1, relation2]}) do
    query1 = do_build_query(object, relation1)
    query2 = do_build_query(object, relation2)

    union_all(query1, ^query2)
  end

  defp do_build_query(object, {:>, [relation1, relation2]}) do
    base = do_build_query(object, relation1)
    query = do_build_query(base, relation2)

    query
  end

  defp do_build_query(object, {:-, [relation1, relation2]}) do
    query1 = do_build_query(object, relation1)
    query2 = do_build_query(object, relation2)

    except_all(query1, ^query2)
  end

  defp do_build_query(object, {:&&, [relation1, relation2]}) do
    query1 = do_build_query(object, relation1)
    query2 = do_build_query(object, relation2)

    from(q in subquery(query1), intersect: ^query2, select: q)
  end

  defp do_build_query(object, relation) when is_atom(relation) do
    query = read_query(object, "#{relation}")

    do_build_query(object, query)
  end

  defp do_build_query(_, %Ecto.Query{} = query) do
    query
  end
end
