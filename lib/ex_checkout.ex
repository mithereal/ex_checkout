defmodule ExCheckout do
  @moduledoc """
  Documentation for `ExCheckout`.
  """

  @doc """
  init.

  ## Examples

      iex> ExCheckout.init()
      :ok

  """
  def init do
    :ok
  end

  @doc """
  Start a Checkout.

  ## Examples

      iex>  {status, _} = ExCheckout.new()
      iex>  status == :ok
      true


  """
  def new, do: ExCheckout.Checkout.Supervisor.start_child()

  @doc """
  Returns the name and module tuple.

      iex> ExCheckout.get_modules()
      []
  """
  def get_modules() do
    {:ok, modules} = :application.get_key(:ex_checkout, :modules)

    modules
    |> Stream.map(&Module.split/1)
    |> Stream.filter(fn module ->
      case module do
        [_, "ExCheckout", "Transaction", _] -> true
        ["ExCheckout", "Transaction", _] -> true
        _ -> false
      end
    end)
    |> Stream.map(&Module.concat/1)
    |> Stream.map(&{&1, apply(&1, :module_id, [])})
    |> Enum.map(fn output ->
      output
    end)
  end
end
