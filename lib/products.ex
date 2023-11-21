defmodule ExCheckout.Products do
  @moduledoc false
  alias ExCheckout.Product
  alias ExCheckout.Repo

  def fetch(state) do
    Enum.map(state.items, fn {x, price} ->
      %Product{sku: x, price: price}
    end)
  end

  def products(state) do
    Enum.map(state.items, fn {x, _} ->
      Repo.get_by(Product, sku: x.sku)
    end)
  end
end
