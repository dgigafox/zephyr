defmodule Zephyr.Relation do
  @moduledoc false
  @type t :: %__MODULE__{
          name: String.t(),
          user_types: [Zephyr.UserType.t()]
        }
  defstruct [:name, :user_types]
end
