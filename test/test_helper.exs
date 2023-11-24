Mix.start()
Mix.shell(Mix.Shell.Process)

ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(ExCheckout.Repo, :manual)

{:ok, _} = Application.ensure_all_started(:ex_machina)
