defmodule ExCheckout.Address do
  use ExCheckout.Schema
  import Ecto.Changeset

  schema "checkout_address" do
    field(:address, :string)
    field(:type, :string)
  end

  @doc false
  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:address, :type])
    |> validate_required([:address, :type])
  end

  def new() do
    {:ok, %ExCheckout.Address{}}
  end

  def new(data) do
    {:ok, changeset(ExCheckout.Address, data)}
  end
end

defmodule ExCheckout.Shipping.Address do
use ExCheckout.Schema
  import Ecto.Changeset

  schema "checkout_address" do
    field(:name, :string)
    field(:company_name, :string)
    field(:first_name, :string)
    field(:last_name, :string)
    field(:phone, :string)
    field(:address, :string)
    field(:address_line_2, :string)
    field(:city, :string)
    field(:state, :string)
    field(:postal_code, :string)
    field(:country, :string)
  end


  @type t() :: %__MODULE__{
          first_name: nil | String.t(),
          last_name: nil | String.t(),
          name: nil | String.t(),
          company_name: nil | String.t(),
          phone: nil | String.t(),
          address: String.t(),
          address_line_2: nil | String.t(),
          city: String.t(),
          state: String.t(),
          postal_code: String.t(),
          country: ISO.country_code()
        }

  def new() do
    {:ok, %{}}
  end

  def new(data) do
    {:ok, %{}}
  end
end
