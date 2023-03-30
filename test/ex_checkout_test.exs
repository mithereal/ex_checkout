defmodule ExCheckoutTest do
  use ExUnit.Case
  # doctest ExCheckout
  alias ExCheckout.Server, as: Checkout
  alias ExCheckout.Transaction

  test "checkout process using invalid data passed to the items array (each product price is really 100)" do
    customer = %{
      first_name: "mithereal",
      last_name: "nil",
      email: "mithereal@gmail.com",
      phone: "1234567"
    }

    items = [{"sku-123", 11.00}, {"sku-123-456", 15.00}]
    adjustments = []
    transaction_data = %Transaction{data: %{id: 12345, response: "JSON"}}

    {:ok, pid} = ExCheckout.new()

    Checkout.customer(pid, customer)
    Checkout.items(pid, items)
    Checkout.adjustments(pid, adjustments)
    Checkout.scan_items(pid)

    _subtotal = Checkout.subtotal(pid)

    total = Checkout.total(pid)

    _invoice = Checkout.invoice(pid)

    _state = Checkout.payment_transaction(pid, transaction_data)
    _receipt = Checkout.receipt(pid)

    assert total == 200
  end
end
