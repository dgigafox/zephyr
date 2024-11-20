defmodule Zephyr.UserType do
  @moduledoc false
  @type t :: %__MODULE__{
          expr: String.t()
        }

  defstruct [:expr]
end
