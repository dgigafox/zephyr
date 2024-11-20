defmodule Zephyr.Permission do
  @moduledoc false
  @type t :: %__MODULE__{
          name: String.t(),
          expr: tuple()
        }

  defstruct [:name, :expr]
end
