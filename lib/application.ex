defmodule ExCheckout.Application do
  @moduledoc false

  use Application

  @name __MODULE__


  def start(_, args) do
    [repo] = Application.get_env(:ex_checkout, :ecto_repos)

    children = [
      ExCheckout.Registry,
      {repo, args},
      {DynamicSupervisor, strategy: :one_for_one, name: ExCheckout.Checkout.Supervisor}
    ]

    opts = [
      strategy: :one_for_one,
      name: @name
    ]

    Supervisor.start_link(children, opts)
  end

  @version Mix.Project.config()[:version]
  def version, do: @version
end
