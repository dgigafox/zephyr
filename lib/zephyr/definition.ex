defmodule Zephyr.Definition do
  @doc """
  Macro for defining an object. An object represents instances of resources or subjects
  in the system.

  Example in your `my_app/lib/my_app/definitions.ex` file you may write:
  ```
  import Zephyr.Definition

  definition(:users)

  definition :organizations do
    relation(:member, :users)
  end
  ```
  """
  alias Zephyr.Helpers

  defmacro definition(name, do: block) do
    module = Helpers.write_definition_module(name)

    quote do
      defmodule unquote(module) do
        use Zephyr.Definition
        unquote(block)
      end
    end
  end

  defmacro definition(name) do
    module = Helpers.write_definition_module(name)

    quote do
      defmodule unquote(module) do
        use Zephyr.Definition
      end
    end
  end

  defmacro relation(relation_name, expr) do
    define_relation(relation_name, expr)
  end

  defp define_relation(relation_name, relation) when is_atom(relation) do
    quote do
      def relation(unquote(relation_name)) do
        unquote(Zephyr.Operations.>(relation, nil))
      end
    end
  end

  defp define_relation(relation_name, expr) do
    quote do
      def relation(unquote(relation_name)) do
        unquote(expr)
      end
    end
  end

  defmacro __using__(_opts) do
    quote do
      import Zephyr.Definition
      import Kernel, except: [+: 2, -: 2, >: 2, &&: 2]
      import Zephyr.Operations
    end
  end
end
