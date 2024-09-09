defmodule Zephyr.Test.Case do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Zephyr.Test.Repo

      import Ecto
      import Ecto.Query
      import Zephyr.Test.Case

      # and any other stuff
    end
  end

  setup tags do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(Zephyr.Test.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
    :ok
  end

  def build_dummy_schema(table, id) do
    %Zephyr.Test.DummySchema{}
    |> Ecto.put_meta(source: table)
    |> Map.put(:id, id)
  end
end
