defmodule Zephyr.QueryBuilder do
  @moduledoc """
  Traverse the resolved relations and build the query.
  """
  import Ecto.Query
  alias Zephyr.Node
  alias Zephyr.QueryParams
  alias Zephyr.RelationTuple

  def read_query(object, %QueryParams{} = params) do
    {initial_query, cte_name} =
      case object do
        %Ecto.Query{from: %{source: {table, _}}} = query ->
          query = exclude(query, :select)

          query =
            RelationTuple
            |> where([r], r.object_key in subquery(query |> select([:subject_key])))
            |> where([r], r.object_namespace in subquery(query |> select([:subject_namespace])))
            |> where(object_predicate: ^params.object_predicate)

          {query, "#{table}_#{params.object_predicate}"}

        _object ->
          query =
            RelationTuple
            |> where(object_key: ^params.object_key)
            |> where(object_namespace: ^params.object_namespace)
            |> where(object_predicate: ^params.object_predicate)

          {query, "#{params.object_namespace}_#{params.object_predicate}"}
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
  end

  def build_query(relations, object) do
    do_build_query(object, relations)
  end

  defp do_build_query(object, {ops, [node1, node2]}) when ops in [:+, :-, :&&] do
    query1 = do_build_query(object, node1)
    query2 = do_build_query(object, node2)

    case ops do
      :+ -> union_all(query1, ^query2)
      :- -> except_all(query1, ^query2)
      :&& -> from(q in subquery(query1), intersect: ^query2, select: q)
    end
  end

  defp do_build_query(object, {:>, [node1, node2]}) do
    base = do_build_query(object, node1)
    query = do_build_query(base, node2)

    query
  end

  defp do_build_query(%Ecto.Query{} = object, %Node{} = node) do
    query =
      object
      |> read_query(%QueryParams{object_predicate: "#{node.name}"})

    do_build_query(object, query)
  end

  defp do_build_query(object, %Node{} = node) do
    query =
      object
      |> read_query(%QueryParams{
        object_namespace: Ecto.get_meta(object, :source),
        object_key: object.id,
        object_predicate: "#{node.name}"
      })

    do_build_query(object, query)
  end

  defp do_build_query(_, %Ecto.Query{} = query) do
    query
    |> select([:subject_key, :subject_namespace, :subject_predicate])
  end
end
