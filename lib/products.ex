defmodule ExCheckout.Products do
  @moduledoc false
  alias ExCheckout.Product

  def fetch(state) do
    Enum.map(state.items, fn {x, price} ->
      %Product{sku: x, price: price}
    end)
  end
end
