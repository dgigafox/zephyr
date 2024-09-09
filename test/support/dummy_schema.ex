defmodule Zephyr.Test.DummySchema do
  use Ecto.Schema

  schema "abstract: dummy" do
    timestamps()
  end
end
