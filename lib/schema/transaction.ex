defmodule ExCheckout.Transaction do
  defstruct data: []

  def id() do
    {:ok, 0}
  end

  def module_id() do
    __MODULE__
  end

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
      |> Enum.map(fn {k,c} ->
        module = Keyword.get(c, :module)

        case module do
          nil ->
            Enum.filter(default_modules, fn {_module, module_transaction} -> module_transaction == k end)

          module ->
            {k, module}
        end
      end)
      |> IO.inspect()
      |> Enum.reject(fn x -> x == nil end)


    module =
      case Enum.filter(transactions, fn {k,_} ->  k == transaction end) do
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
end
