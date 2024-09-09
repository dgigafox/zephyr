defmodule Zephyr.Test.Helpers do
  @moduledoc false
  alias Zephyr.Helpers

  defmacro test_definition(name, do: block) do
    module = Helpers.get_definition(name)

    quote do
      defmodule unquote(module) do
        use Zephyr.Definition
        unquote(block)
      end
    end
  end
end
