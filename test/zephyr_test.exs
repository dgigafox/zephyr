defmodule ZephyrTest do
  use ExUnit.Case
  doctest Zephyr

  test "greets the world" do
    assert Zephyr.hello() == :world
  end
end
