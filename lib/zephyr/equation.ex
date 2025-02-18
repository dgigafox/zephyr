defmodule Zephyr.Equation do
  @moduledoc false
  @type permission() :: atom()
  @type permission_token() :: {:permission, map(), String.t()}

  @spec build(Graph.t(), permission_token()) :: tuple() | String.t()
  def build(graph, permission_token) do
    neighbors = Graph.out_neighbors(graph, permission_token)
    do_build_equation(graph, neighbors)
  end

  defp do_build_equation(graph, [{:operator, _meta, operator} = token]) do
    [left, right] = Graph.out_neighbors(graph, token)
    {operator, do_build_equation(graph, [left]), do_build_equation(graph, [right])}
  end

  defp do_build_equation(graph, [{:permission, _meta, _permission} = token]) do
    do_build_equation(graph, Graph.out_neighbors(graph, token))
  end

  defp do_build_equation(_graph, [{:relation, _meta, relation}]) do
    relation
  end
end
