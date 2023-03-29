defmodule ExCheckout.Products  do
  @moduledoc false
  
  alias ExCheckout.Product

def products(state) do
  [repo] = Application.get_env(:ex_checkout, :ecto_repos)

    Enum.map(state.products, fn {x, _} ->
      repo.get_by(Product, x, :sku)
    end)
end
end