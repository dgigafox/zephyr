defmodule Zephyr.RelationResolver do
  @moduledoc """
  Traverse the AST and resolve relations to their respective modules.
  """
  alias Zephyr.Helpers

  def run(definition_module, permission) do
    (definition_module.permission(permission) || raise("Permission named #{permission} not found"))
    |> do_run(%{module: definition_module, permission: permission})
  end

  defp do_run({ops, [left, right]}, state) when ops in [:+, :-, :&&] do
    {ops, [do_run(left, state), do_run(right, state)]}
  end

  defp do_run({:>, [definition, permission_or_relation]}, _state) do
    module = get_definition_module_from_relation(definition)
    run(module, permission_or_relation)
  end

  defp do_run(relation_or_permission, %{module: module} = state)
       when is_atom(relation_or_permission) do
    get_permission_or_relation(module, relation_or_permission)
    |> do_run(state)
  end

  defp do_run({:permission, _permission, expr}, state) do
    do_run(expr, state)
  end

  defp do_run({:relation, relation, _expr}, _state) do
    relation
  end

  defp get_permission_or_relation(module, permission_or_relation) do
    module.permission(permission_or_relation) || module.relation(permission_or_relation) ||
      raise "Permission or relation named #{permission_or_relation} not found"
  end

  defp get_definition_module_from_relation(relation) do
    Helpers.get_definition(relation)
  end
end
