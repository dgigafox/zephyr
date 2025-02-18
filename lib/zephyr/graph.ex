defmodule Zephyr.Graph do
  @moduledoc """
  Tokens are used to represent the different types of nodes in the graph:
  `{token_type, meta, name}`
  """
  alias Ecto.UUID
  alias Graph.Edge

  @spec build(Zephyr.AST.t()) :: Graph.t()
  def build(ast) do
    graph = Graph.new()
    edges = Enum.flat_map(ast.entities, &build_edges/1)

    Graph.add_edges(graph, edges)
  end

  defp build_edges(entity) do
    definition_token = {:definition, %{}, entity.name}
    permissions = Enum.map(entity.permissions, &build_permission_edges(definition_token, &1))

    List.flatten(permissions)
  end

  defp build_permission_edges(definition_token, permission) do
    {:definition, _meta, definition_name} = definition_token

    permission_token = {:permission, %{}, definition_name <> "." <> permission.name}
    permission_edge = Edge.new(definition_token, permission_token)
    edges_from_expr = build_edges_from_expr(permission_token, permission.expr)

    List.flatten([permission_edge | edges_from_expr])
  end

  defp build_edges_from_expr(permission_token, {operator, _, _} = expr) do
    root_operator_token = {:operator, %{id: UUID.generate()}, operator}
    root_edge = Edge.new(permission_token, root_operator_token)

    {_ast, edges} =
      expr
      |> Macro.postwalk([], fn
        # First root operator since acc is empty
        {_operator, _meta, [left, right]} = expr, [] = acc ->
          v1 = Edge.new(root_operator_token, left)
          v2 = Edge.new(root_operator_token, right)
          {expr, [v1, v2 | acc]}

        {operator, _meta, [left, right]} = expr, [_ | _] = acc ->
          operator_token = {:operator, %{id: UUID.generate()}, operator}
          v1 = Edge.new(operator_token, left)
          v2 = Edge.new(operator_token, right)
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
        # [_definition, relation] = String.split(string, "#")
        {:relation, %{}, string}

      String.contains?(string, ".") ->
        # [_definition, permission] = String.split(string, ".")
        {:permission, %{}, string}
    end
  end
end
