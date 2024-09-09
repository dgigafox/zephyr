Application.ensure_all_started(:postgrex)

Zephyr.Test.Repo.start_link()
ExUnit.start(assert_receive_timeout: 500, refute_receive_timeout: 50, exclude: [:skip])
Ecto.Adapters.SQL.Sandbox.mode(Zephyr.Test.Repo, :manual)
