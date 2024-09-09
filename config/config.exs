import Config

config :logger, level: :warning

config :zephyr, Zephyr.Test.Repo,
  migration_lock: false,
  name: Zephyr.Test.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2,
  priv: "test/support/postgres",
  stacktrace: true,
  url: System.get_env("DATABASE_URL") || "postgres://localhost:5432/zephyr_test"

config :zephyr, ecto_repos: [Zephyr.Test.Repo]

import_config "#{config_env()}.exs"
