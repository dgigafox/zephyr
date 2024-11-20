defmodule Zephyr.Equation do
  @moduledoc false
  @type permission() :: atom()

  @spec build(Graph.t()) :: [{permission(), String.t()}]
  def build(graph) do
    list = graph |> Graph.transpose() |> Graph.topsort()
    {:definition, entity} = List.last(list)
    {permissions, _} = Keyword.pop_values(list, :permission)

    Enum.reduce(permissions, {0, []}, fn permission, {start_index, collection} ->
      end_index = Enum.find_index(list, &(&1 == {:permission, permission}))
      children = Enum.slice(list, start_index..(end_index - 1))
      equation = build_equation(entity, children)
      {end_index, [{permission, equation} | collection]}
    end)
  end

  defp build_equation(entity, vertices) do
    do_build_equation(vertices, entity)
  end

  defp do_build_equation([left, right, {:operator, operator} | rest], entity) do
    left = parse(left, entity)
    right = parse(right, entity)
    do_build_equation([{operator, [left, right]} | rest], entity)
  end

  defp do_build_equation([v], entity), do: parse(v, entity)

  defp parse({:relation, relation}, entity) do
    "#{entity}##{relation}"
  end

  defp parse({:permission, permission}, entity) do
    "#{entity}.#{permission}"
  end

  defp parse({_operator, [_left, _right]} = equation, _), do: equation
end
