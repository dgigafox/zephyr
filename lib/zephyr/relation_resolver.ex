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

  # Relation
  defp do_run(%Node{type: :relation} = node) do
    node
  end

  # Permission
  defp do_run(%Node{type: :permission, expr: item} = node) when is_atom(item) do
    node
    |> get_relation_or_permission(item)
    |> do_run()
  end

  # Operations
  defp do_run(%Node{expr: {ops, [left, right]}} = node) when ops in [:+, :-, :&&] do
    {ops, [do_run(%{node | expr: left}), do_run(%{node | expr: right})]}
  end

  defp do_run(%Node{expr: {:>, [left, right]}} = node) do
    left = node.module.relation(left) || raise "No relation named #{left} found"

    definitions =
      left
      |> list_definitions_from_relation()
      |> Enum.map(&get_definition/1)
      |> Enum.map(&get_relation_or_permission(%{module: &1}, right))
      |> Enum.reject(&is_nil/1)
      |> Enum.map(&do_run/1)
      |> build_unions()

    {:>, [left, definitions]}
  end

  # Helpers
  # defp get_relation_or_permission(%{type: :relation} = node, item) when is_atom(item) do
  #   %{node | namespace: item}
  # end

  defp get_relation_or_permission(node, item) when is_atom(item) do
    module = node.module
    module.relation(item) || module.permission(item)
  end

  defp get_definition(item) when is_atom(item) do
    Helpers.get_definition(item)
  end

  def list_definitions_from_relation(%Node{type: :relation, expr: item}) do
    item
    |> Enum.map(fn
      {def, _} -> def
      def -> def
    end)
  end

  def build_unions([node]), do: node

  def build_unions([head | tail]) do
    {:+, [head, build_unions(tail)]}
  end

  def build_unions([a, b]), do: {:+, [a, b]}
end
