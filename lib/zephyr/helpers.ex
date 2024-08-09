defmodule Zephyr.Helpers do
  @moduledoc false

  @doc """
  Appends the name to the definitions module.
  """
  @spec write_definition_module(atom()) :: module()
  def write_definition_module(name) do
    namespace = name |> to_string() |> Macro.camelize()
    Module.concat(Zephyr.Definitions, namespace)
  end
end
