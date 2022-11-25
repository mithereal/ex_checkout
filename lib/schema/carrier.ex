defmodule ExCheckout.Carrier do
  @doc """
  Fetches a Carrier module by its atom/string representation.

      iex> Carrier.module(:ups)
      Carrier.UPS
      iex> Carrier.module("UPS")
      Carrier.UPS
      iex> Carrier.module("ups")
      Carrier.UPS
  """


  @spec module(atom | String.t()) :: module()
  def module(carrier) when is_atom(carrier) do
    default_modules = ExCheckout.get_shipping_modules()

    carriers =
      Application.get_env(:ex_checkout, :carriers, [])
      |> Enum.map(fn {k, c} ->
        module = Keyword.get(c, :module)

        case module do
          nil ->
            Enum.filter(default_modules, fn {_module, module_carrier} -> module_carrier == k end)

          module ->
            {k, module}
        end
      end)
      |> IO.inspect()
      |> Enum.reject(fn x -> x == nil end)

    module =
      case Enum.filter(carriers, fn {k, _} -> k == carrier end) do
        [{_, carrier_module}] -> carrier_module
        {_, carrier_module} -> carrier_module
        c -> raise "#{c} is not a supported carrier at this time."
      end

    available_carriers = ExCheckout.carriers()

    if carrier in available_carriers do
      module
    else
      raise ExCheckout.InvalidConfigError,
            "#{inspect(carrier)} not found in carriers: #{inspect(available_carriers)}"
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
  def module_exists(atom, module_list \\ []) when is_atom(atom) do
    default_modules = ExCheckout.get_carrier_modules()

    carriers =
      Application.get_env(:ex_checkout, :carriers, module_list)
      |> Enum.map(fn {k, c} ->
        module = Keyword.get(c, :module)

        case module do
          nil ->
            Enum.filter(default_modules, fn {_module, module_carrier} ->
              module_carrier == k
            end)

          module ->
            {k, module}
        end
      end)
      |> IO.inspect()
      |> Enum.reject(fn x -> x == nil end)

    module =
      case Enum.filter(carriers, fn {k, _} -> k == atom end) do
        [{_, carrier_module}] -> carrier_module
        {_, carrier_module} -> carrier_module
        _ -> %{}
      end

    available_providers = ExCheckout.available_carriers()

    if module in available_providers do
      true
    else
      false
    end
  end
end
