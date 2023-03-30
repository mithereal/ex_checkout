defmodule ExCheckout.Carrier.Null do
  @moduledoc """
  Example Shipping module
  """
  @behaviour ExCheckout.Behaviours.Carrier

  @impl true
  def carrier() do
    nil
  end
end
