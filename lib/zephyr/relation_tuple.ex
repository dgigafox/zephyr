defmodule Zephyr.RelationTuple do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @subject_key_type Application.compile_env(:zephyr, :subject_key_type, :integer)
  @object_key_type Application.compile_env(:zephyr, :object_key_type, :integer)

  @type t :: %__MODULE__{}

  schema "zephyr_relations" do
    field(:subject_namespace, :string)
    field(:subject_key, @subject_key_type)
    field(:subject_predicate, :string)
    field(:object_namespace, :string)
    field(:object_key, @object_key_type)
    field(:object_predicate, :string)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(relation_tuple, attrs) do
    relation_tuple
    |> cast(attrs, [
      :subject_namespace,
      :subject_key,
      :subject_predicate,
      :object_namespace,
      :object_key,
      :object_predicate
    ])
    |> validate_required([
      :subject_namespace,
      :subject_key,
      :object_namespace,
      :object_key,
      :object_predicate
    ])
  end
end
