defmodule Zephyr.Helpers do
  @moduledoc false

  @doc """
  Appends the name to the definitions module.
  """
  @spec get_definition(atom() | String.t()) :: module()
  def get_definition(name) do
    namespace = name |> to_string() |> Macro.camelize()
    Module.concat(Zephyr.Definitions, namespace)
  end
end
