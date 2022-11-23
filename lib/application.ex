defmodule ExCheckout.Application do
  use Application

  def start(_type, args) do
    children = [
    {Application.Repo, args},
      ExCheckout.Supervisor
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  @version Mix.Project.config()[:version]
  def version, do: @version
end
