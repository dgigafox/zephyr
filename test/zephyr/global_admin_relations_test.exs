defmodule Zephyr.GlobalAdminRelationsTest do
  use Zephyr.Test.Case

  setup do
    Zephyr.write!(
      {"global_users", "drevil", nil},
      {"global_platforms", "evilempire", "administrator"}
    )

    Zephyr.write!(
      {"global_platforms", "evilempire", nil},
      {"global_organizations", "virtucon", "platform"}
    )

    Zephyr.write!(
      {"global_organizations", "virtucon", nil},
      {"global_resources", "lasers", "owner"}
    )

    :ok
  end

  test "check/3" do
    object = build_dummy_schema("global_resources", "lasers")
    drevil = build_dummy_schema("global_users", "drevil")

    assert Zephyr.check(object, "admin", drevil)
  end
end
