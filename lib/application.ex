defmodule ExCheckout.Application do
  use Application

  def start(arg, nil) do
    start(arg, [])
  end

  def start(_, args) do
    children = [
      {ExCheckout.Repo, args},
      ExCheckout.Supervisor
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  @version Mix.Project.config()[:version]
  def version, do: @version
end
