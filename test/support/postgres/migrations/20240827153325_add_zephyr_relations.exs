defmodule Zephyr.Test.Repo.Migrations.AddZephyrRelations do
  use Ecto.Migration

  def up do
    Zephyr.Migrations.up()
  end

  def down do
    Zephyr.Migrations.down()
  end
end
