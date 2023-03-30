defmodule ExCheckout.Products do
  @moduledoc false
  alias ExCheckout.Product

  def fetch(state) do
    Enum.map(state.items, fn {x, _} ->
      %Product{sku: x}
    end)
  end
end
