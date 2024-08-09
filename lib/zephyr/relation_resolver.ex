defmodule Zephyr.RelationResolver do
  @moduledoc """
  Traverse the AST and resolve relations to their respective modules.
  """
  alias Zephyr.Helpers

  @spec resolve_relation(module(), atom()) :: any()
  def resolve_relation(definition_module, relation) do
    definition_module.relation(relation)
    |> do_resolve_relation(definition_module, relation)
  end

  defp do_resolve_relation({:+, [left, right]}, module, relation) do
    {:+,
     [
       do_resolve_relation(left, module, relation),
       do_resolve_relation(right, module, relation)
     ]}
  end

  defp do_resolve_relation({:-, [left, right]}, module, relation) do
    {:-,
     [
       do_resolve_relation(left, module, relation),
       do_resolve_relation(right, module, relation)
     ]}
  end

  defp do_resolve_relation({:&&, [left, right]}, module, relation) do
    {:&&,
     [
       do_resolve_relation(left, module, relation),
       do_resolve_relation(right, module, relation)
     ]}
  end

  defp do_resolve_relation({:>, [_, nil]}, _module, relation) do
    relation
  end

  defp do_resolve_relation({:>, [left, right]}, module, _relation) do
    relation = module.relation(left)
    module = get_definition_module_from_relation(relation)
    {:>, [left, resolve_relation(module, right)]}
  end

  defp do_resolve_relation(:_this, _module, relation) do
    relation
  end

  defp do_resolve_relation(relation, module, _) do
    module.relation(relation)
    |> do_resolve_relation(module, relation)
  end

  defp get_definition_module_from_relation({:>, [relation, _]}) do
    Helpers.get_definition(relation)
  end

  defp get_definition_module_from_relation(relation) do
    Helpers.get_definition(relation)
  end
end
