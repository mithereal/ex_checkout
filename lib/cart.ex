defmodule ExCheckout.Cart  do
  @moduledoc false

  alias ExCheckout.Product

def products(cart) do
  [repo] = Application.get_env(:ex_checkout, :ecto_repos)

    Enum.map(cart.items, fn {x, _} ->
      repo.get_by(Product, x, :sku)
    end)
end
end