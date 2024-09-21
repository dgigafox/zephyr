defmodule Zephyr.BasicRelationsTest do
  use Zephyr.Test.Case

  setup do
    Zephyr.write!(
      {"basic_users", "somegal", nil},
      {"basic_documents", "someresource", "reader"}
    )

    Zephyr.write!(
      {"basic_users", "anotherguy", nil},
      {"basic_documents", "someresource", "writer"}
    )

    Zephyr.write!(
      {"basic_users", "somegal", nil},
      {"basic_documents", "anotherresource", "writer"}
    )

    :ok
  end

  test "check/3" do
    object = build_dummy_schema("basic_documents", "someresource")

    somegal = build_dummy_schema("basic_users", "somegal")
    assert Zephyr.check(object, "read", somegal)

    anotherguy = build_dummy_schema("basic_users", "anotherguy")
    assert Zephyr.check(object, "read", anotherguy)

    assert Zephyr.check(object, "write", anotherguy)

    refute Zephyr.check(object, "write", somegal)
  end
end
