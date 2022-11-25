defmodule ExCheckout.Transaction do
  defstruct id: nil,
            data: []

  alias ExCheckout.Transaction

  @doc """
  Return the module id
  """
  def id() do
    {:ok, 0}
  end

  @doc """
  Return the module id
  """
  def module_id() do
    __MODULE__
  end

  @doc """
  Run the module process.
  """
  def process(data) do
    {:ok, data}
  end

  @doc """
  Fetches a Transaction module by its atom/string representation.

      iex> Transaction.module(:ups)
      Transaction.UPS
      iex> Transaction.module("UPS")
      Transaction.UPS
      iex> Transaction.module("ups")
      Transaction.UPS
  """
  @spec module(atom | String.t()) :: module()
  def module(transaction) when is_atom(transaction) do
    default_modules = ExCheckout.get_transaction_modules()

    transactions =
      Application.get_env(:ex_checkout, :payment_providers, [])
      |> Enum.map(fn {k, c} ->
        module = Keyword.get(c, :module)

        case module do
          nil ->
            Enum.filter(default_modules, fn {_module, module_transaction} ->
              module_transaction == k
            end)

          module ->
            {k, module}
        end
      end)
      |> IO.inspect()
      |> Enum.reject(fn x -> x == nil end)

    module =
      case Enum.filter(transactions, fn {k, _} -> k == transaction end) do
        [{_, transaction_module}] -> transaction_module
        {_, transaction_module} -> transaction_module
        c -> raise "#{c} is not a supported transaction type at this time."
      end

    available_providers = ExCheckout.payment_providers()

    if transaction in available_providers do
      module
    else
      raise ExCheckout.InvalidConfigError,
            "#{inspect(transaction)} not found in providers: #{inspect(available_providers)}"
    end
  end

  def module(string) when is_binary(string) do
    string
    |> String.downcase()
    |> String.to_atom()
    |> module
  end

  @doc """
  Checks if Module Exists.

      iex> Transaction.module_exists(:ups)
      true
      iex> Transaction.module_exists("UPS")
      true
      iex> Transaction.module_exists("ups")
      true
  """
  def module_exists(atom) when is_atom(atom) do
    default_modules = ExCheckout.get_transaction_modules()

    transactions =
      Application.get_env(:ex_checkout, :payment_providers, [])
      |> Enum.map(fn {k, c} ->
        module = Keyword.get(c, :module)

        case module do
          nil ->
            Enum.filter(default_modules, fn {_module, module_transaction} ->
              module_transaction == k
            end)

          module ->
            {k, module}
        end
      end)
      |> IO.inspect()
      |> Enum.reject(fn x -> x == nil end)

    module =
      case Enum.filter(transactions, fn {k, _} -> k == atom end) do
        [{_, transaction_module}] -> transaction_module
        {_, transaction_module} -> transaction_module
        _ -> %Transaction{}
      end

    available_providers = ExCheckout.payment_providers()

    if module in available_providers do
      true
    else
      false
    end
  end
end
