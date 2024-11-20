defmodule Zephyr.Entity do
  @moduledoc false
  @type t :: %__MODULE__{
          name: String.t(),
          relations: [Zephyr.Relation.t()],
          permissions: [Zephyr.Permission.t()]
        }
  defstruct [:name, :relations, :permissions]
end
