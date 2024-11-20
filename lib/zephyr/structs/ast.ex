defmodule Zephyr.AST do
  @moduledoc false
  @type t :: %__MODULE__{entities: [Zephyr.Entity.t()]}
  defstruct [:entities]
end
