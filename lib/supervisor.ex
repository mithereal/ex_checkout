defmodule ExCheckout.Checkout.Supervisor do
  use DynamicSupervisor

  @name __MODULE__

  def child_spec([args]) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, args},
      type: :supervisor
    }
  end

  def start_child(args \\ nil) do
    spec = {ExCheckout.Server, args}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def start_link(args \\ []) do
    DynamicSupervisor.start_link(__MODULE__, args, name: @name)
  end

  def start() do
    start_link()
  end

  def stop(id) do
    Process.exit(id, :shutdown)
    :ok
  end

  def init(args) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      extra_arguments: args
    )
  end
end
