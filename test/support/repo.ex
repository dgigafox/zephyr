defmodule Zephyr.Test.Repo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :zephyr,
    adapter: Ecto.Adapters.Postgres
end
