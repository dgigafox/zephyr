defmodule Zephyr.Graph do
  @moduledoc false
  alias Graph.Edge

  @spec build(Zephyr.AST.t()) :: Graph.t()
  def build(ast) do
    graph = Graph.new()
    edges = Enum.flat_map(ast.entities, &build_edges/1)

    Graph.add_edges(graph, edges)
  end

  defp build_edges(entity) do
    definition_token = {:definition, entity.name}
    relations = Enum.map(entity.relations, &build_relation_edges(definition_token, &1))
    permissions = Enum.map(entity.permissions, &build_permission_edges(definition_token, &1))

    List.flatten([relations, permissions])
  end

  defp build_relation_edges(definition_token, relation) do
    relation_token = {:relation, relation.name}
    Edge.new(definition_token, relation_token)
  end

  defp build_permission_edges(definition_token, permission) do
    permission_token = {:permission, permission.name}
    permission_edge = Edge.new(definition_token, permission_token)
    edges_from_expr = build_edges_from_expr(permission_token, permission.expr)

    List.flatten([permission_edge | edges_from_expr])
  end

  defp build_edges_from_expr(permission_token, {operator, _, _} = expr) do
    root_edge = Edge.new(permission_token, {:operator, operator})

    {_ast, edges} =
      expr
      |> Macro.postwalk([], fn
        {operator, _meta, [left, right]} = expr, [] = acc ->
          v1 = Edge.new({:operator, operator}, left)
          v2 = Edge.new({:operator, operator}, right)
          {expr, [v1, v2 | acc]}

        other, acc ->
          token = relation_to_token(other)
          {token, acc}
      end)

    [root_edge | edges]
  end

  defp build_edges_from_expr(permission_token, relation) do
    relation_token = relation_to_token(relation)
    [Edge.new(permission_token, relation_token)]
  end

  defp relation_to_token(string) do
    cond do
      String.contains?(string, "#") ->
        [_definition, relation] = String.split(string, "#")
        {:relation, relation}

      String.contains?(string, ".") ->
        [_definition, permission] = String.split(string, ".")
        {:permission, permission}
    end
  end
end
