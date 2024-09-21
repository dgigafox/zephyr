defmodule Zephyr.RelationResolver do
  @moduledoc """
  Traverse the AST and resolve relations to their respective modules.
  """
  alias Zephyr.Helpers
  alias Zephyr.Node

  def run(definition_module, permission) do
    (definition_module.permission(permission) || raise("Permission named #{permission} not found"))
    |> do_run()
  end

  # Leaf
  defp do_run(%Node{namespace: subject} = node) when not is_nil(subject) do
    node
  end

  # Relation
  defp do_run(%Node{type: :relation, expr: item} = node) when is_atom(item) do
    node
    |> get_relation_or_permission(item)
    |> do_run()
  end

  # Permission
  defp do_run(%Node{type: :permission, expr: item} = node) when is_atom(item) do
    node
    |> get_relation_or_permission(item)
    |> do_run()
  end

  # Operations
  defp do_run(%Node{expr: {ops, [left, right]}} = node) when ops in [:+, :-, :&&] do
    # left = :gm_users
    # right = {:>, [:gm_groups, :membership]}
    {ops, [do_run(%{node | expr: left}), do_run(%{node | expr: right})]}
  end

  defp do_run(%Node{expr: {:>, [left, right]}} = node) do
    module = get_definition(left)

    left = %{node | type: :definition, expr: left, namespace: left}

    node =
      %{module: module}
      |> get_relation_or_permission(right)
      |> do_run()

    {:>, [left, node]}
  end

  # Helpers
  defp get_relation_or_permission(%{type: :relation} = node, item) when is_atom(item) do
    %{node | namespace: item}
  end

  defp get_relation_or_permission(node, item) when is_atom(item) do
    module = node.module
    module.relation(item) || module.permission(item)
  end

  defp get_definition(item) when is_atom(item) do
    Helpers.get_definition(item)
  end
end
