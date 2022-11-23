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

  def start_child(args \\ []) do
    child_spec = %{
      id: ExCheckout.Server,
      start: {ExCheckout.Server, :start_link, args},
      restart: :transient
    }
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def start_link(args \\ []) do
    DynamicSupervisor.start_link(__MODULE__, args, name: @name)
  end

  def stop_checkout(pid) do
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end

  def init(args) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      extra_arguments: args
    )
  end
end
