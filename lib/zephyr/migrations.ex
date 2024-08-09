defmodule Zephyr.Migrations do
  @moduledoc "API for calling up and down in Ecto migrations"
  use Ecto.Migration

  @doc """
  Migrates storage up to the latest version.
  """
  @callback up(Keyword.t()) :: :ok

  @doc """
  Migrates storage down to the previous version.
  """
  @callback down(Keyword.t()) :: :ok

  def up(opts \\ []) when is_list(opts) do
    migrator().up(opts)
  end

  def down(opts \\ []) when is_list(opts) do
    migrator().down(opts)
  end

  defp migrator do
    case repo().__adapter__() do
      Ecto.Adapters.Postgres -> Zephyr.Migrations.Postgres
      _ -> raise "Unsupported adapter"
    end
  end
end
