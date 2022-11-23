defmodule ExCheckout.Application do
  @moduledoc false

  use Application

  def start(_, args) do
    children = [
      {ExCheckout.Repo, args},
      {DynamicSupervisor, strategy: :one_for_one, name: ExCheckout.Checkout.Supervisor}
    ]

    opts = [
      strategy: :one_for_one,
      name: ExCheckout.Supervisor
    ]

    Supervisor.start_link(children, opts)
  end

  @version Mix.Project.config()[:version]
  def version, do: @version
end
