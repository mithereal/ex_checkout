defmodule ExCheckout.Address do
  defstruct address: nil,
            type: :billing

  def new() do
    :ok
  end
end

defmodule ExCheckout.Shipping.Address do
  @enforce_keys ~w(first_name last_name name phone address address_line_2 city
                   state postal_code country)a

  defstruct ~w(first_name last_name name company_name phone address
               address_line_2 city state postal_code country)a

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

  def new(params) do
    :ok
  end
end
