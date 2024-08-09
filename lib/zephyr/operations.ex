defmodule Zephyr.Operations do
  @moduledoc """
  Represents the operations that can be performed between relations.
  Union, intersection, exclusion, and arrow are among the supported operations
  """

  @doc "Exclusion operator"
  def left - right do
    {:-, [left, right]}
  end

  @doc "Union operator"
  def left + right do
    {:+, [left, right]}
  end

  @doc "Arrow operator"
  def left > right do
    {:>, [left, right]}
  end

  @doc "Intersection operator"
  def left && right do
    {:&&, [left, right]}
  end
end
