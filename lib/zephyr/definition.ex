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
  alias Zephyr.Node

  defmacro definition(name, do: block) do
    module = Helpers.get_definition(name)

    quote do
      defmodule unquote(module) do
        use Zephyr.Definition
        unquote(block)
      end
    end
  end

  defmacro definition(name) do
    module = Helpers.get_definition(name)

    quote do
      defmodule unquote(module) do
        use Zephyr.Definition
      end
    end
  end

  defmacro relation(relation_name, expr) do
    define_relation(relation_name, expr)
  end

  # defp define_relation(relation_name, relation) when is_atom(relation) do
  #   quote do
  #     def relation(unquote(relation_name)) do
  #       unquote(Zephyr.Operations.>(relation, nil))
  #     end
  #   end
  # end

  defp define_relation(name, expr) do
    quote do
      def relation(unquote(name)) do
        %Node{
          module: __MODULE__,
          type: :relation,
          name: unquote(name),
          expr: unquote(expr)
        }
      end
    end
  end

  defmacro permission(name, expr) do
    quote do
      def permission(unquote(name)) do
        %Node{
          module: __MODULE__,
          type: :permission,
          name: unquote(name),
          expr: unquote(expr)
        }
      end
    end
  end

  defmacro __using__(_opts) do
    quote do
      @before_compile Zephyr.Definition
      import Zephyr.Definition
      import Kernel, except: [+: 2, -: 2, >: 2, &&: 2]
      import Zephyr.Operations
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def relation(_name), do: nil
      def permission(_name), do: nil
    end
  end
end
