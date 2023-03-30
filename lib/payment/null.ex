defmodule ExCheckout.Transaction.Null do
  @moduledoc """
  Example Payment module
  """
  @behaviour ExCheckout.Behaviours.Transaction

  @impl true
  def module_id() do
    :null
  end
end
