defmodule ExCheckout.Shipment do
  @moduledoc """
  A `Shipment` represents everything needed to fetch rates from carriers: an
  origin, a destination, and a package description. An optional `:id` field
  is provided in the struct, which may be used by the end user to represent the
  user's internal identifier for the shipment. The id is not used by ExCheckout.

  Shipments are created by `shipment/3`.
  """

  alias ExCheckout.Shipment, as: Shipment
  alias ExCheckout.Address, as: Address
  alias ExCheckout.Package, as: Package

  @enforce_keys [:from, :to, :package, :ship_date]
  defstruct [:id, :from, :to, :package, :ship_date]

  @type t :: %__MODULE__{
          id: any(),
          from: Address.t(),
          to: Address.t(),
          package: Package.t(),
          ship_date: any()
        }

  @doc """
  Builds a `Shipment`.
  """
  @spec new(Address.t(), Address.t(), Package.t(), Keyword.t()) ::
          {:ok, t()}
  def new(%Address{} = from, %Address{} = to, %Package{} = package, opts \\ []) do
    ship_date = Keyword.get(opts, :ship_date)

    shipment = %Shipment{
      from: from,
      to: to,
      package: package,
      ship_date: ship_date
    }

    {:ok, shipment}
  end

  @doc """
  Builds a `Shipment`. Raises on failure.
  """
  @spec new!(Address.t(), Address.t(), Package.t(), Keyword.t()) :: t() | none()
  def new!(%Address{} = from, %Address{} = to, %Package{} = package, opts \\ []) do
    new(from, to, package, opts)
  end
end
