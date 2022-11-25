defmodule ExCheckout do
  @moduledoc """
  Documentation for `ExCheckout`.
  """

  alias ExCheckout.Config

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

      iex> ExCheckout.get_transaction_modules()
      []
  """
  def get_transaction_modules() do
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

  @doc """
  Returns the name and module tuple.

      iex> ExCheckout.get_shipping_modules()
      []
  """
  def get_shipping_modules() do
    {:ok, modules} = :application.get_key(:ex_checkout, :modules)

    modules
    |> Stream.map(&Module.split/1)
    |> Stream.filter(fn module ->
      case module do
        ["Shippex", "Carrier", "_", "Client"] -> false
        ["ExCheckout", "Carrier", "_", "Client"] -> false
        [_, "Shippex", "Carrier", "Client"] -> false
        [_, "ExCheckout", "Carrier", "Client"] -> false
        ["Shippex", "Carrier", _] -> true
        [_, "Shippex", "Carrier", _] -> true
        ["ExCheckout", "Carrier", _] -> true
        [_, "ExCheckout", "Carrier", _] -> true
        _ -> false
      end
    end)
    |> Stream.map(&Module.concat/1)
    |> Stream.map(&{&1, apply(&1, :carrier, [])})
    |> Enum.map(fn output ->
      output
    end)
  end

  @doc false
  defdelegate carriers(), to: Config

  @doc false
  defdelegate carriers(list), to: Config

  @doc false
  defdelegate payment_providers(), to: Config

  @doc false
  defdelegate payment_providers(list), to: Config

  @version Mix.Project.config()[:version]
  def version, do: @version

  @doc """
  Returns the available shipping carriers.

      iex> ExCheckout.available_carriers()
      []
  """
  def available_carriers() do
    Config.carriers()
    |> Enum.filter(fn x ->
      ExCheckout.Transaction.module_exists(x)
    end)
  end

  @doc """
  Returns the the available payment processors.

      iex> ExCheckout.available_payment_processors()
      []
  """
  def available_payment_processors() do
    Config.payment_providers()
    |> Enum.filter(fn x ->
      ExCheckout.Transaction.module_exists(x)
    end)
  end
end
