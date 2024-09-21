defmodule Zephyr.GroupMembershipRelationsTest do
  use Zephyr.Test.Case

  setup do
    Zephyr.write!(
      {"gm_users", "chico", nil},
      {"gm_groups", "sharks", "admin"}
    )

    Zephyr.write!(
      {"gm_users", "gus", nil},
      {"gm_roles", "cast", "member"}
    )

    Zephyr.write!(
      {"gm_groups", "sharks", "membership"},
      {"gm_roles", "cast", "member"}
    )

    :ok
  end

  test "check/3" do
    object = build_dummy_schema("gm_roles", "cast")

    chico = build_dummy_schema("gm_users", "chico")
    gus = build_dummy_schema("gm_users", "gus")

    assert Zephyr.check(object, "allowed", chico)
    assert Zephyr.check(object, "allowed", gus)
  end
end
