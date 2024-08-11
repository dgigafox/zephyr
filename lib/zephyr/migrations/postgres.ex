defmodule Zephyr.Migrations.Postgres do
  @moduledoc false
  @behaviour Zephyr.Migrations
  use Ecto.Migration

  @subject_key_type Application.compile_env(:zephyr, :subject_key_type, :integer)
  @object_key_type Application.compile_env(:zephyr, :object_key_type, :integer)

  @impl Zephyr.Migrations
  def up(opts) do
    opts =
      opts
      |> Keyword.put_new(:prefix, "public")
      |> Keyword.put_new(:subject_key_type, @subject_key_type)
      |> Keyword.put_new(:object_key_type, @object_key_type)
      |> Map.new()

    create table(:zephyr_relations, prefix: opts.prefix) do
      add(:subject_namespace, :string)
      add(:subject_key, opts.subject_key_type)
      add(:subject_predicate, :string)
      add(:object_namespace, :string)
      add(:object_key, opts.object_key_type)
      add(:object_predicate, :string)

      timestamps(type: :utc_datetime)
    end
  end

  @impl Zephyr.Migrations
  def down(opts) do
    opts = Keyword.put_new(opts, :prefix, "public")
    drop(table(:zephyr_relations, opts))
  end
end
