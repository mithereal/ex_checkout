defmodule ExCheckout.Carrier.Null do
  @moduledoc false

  @impl true
  def carrier() do
    :usps
  end
end
