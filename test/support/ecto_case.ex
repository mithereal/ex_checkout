defmodule ExCheckout.EctoCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias ExCheckout.Repo

      import Ecto
      import Ecto.Query
      import ExCheckout.EctoCase
      import ExCheckout.Factory

      # and any other stuff
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ExCheckout.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(ExCheckout.Repo, {:shared, self()})
    end

    :ok
  end
end
