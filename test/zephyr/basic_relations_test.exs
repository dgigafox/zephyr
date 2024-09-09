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

  test "user:somegal can read someresource" do
    subject = build_dummy_schema("basic_users", "somegal")
    object = build_dummy_schema("basic_documents", "someresource")

    assert Zephyr.check(object, "read", subject)
  end
end
