defmodule ExCheckoutTest do
  use ExUnit.Case
  # doctest ExCheckout
  alias ExCheckout.Server, as: Checkout
  alias ExCheckout.Transaction

  test "init" do
    assert ExCheckout.init() == :ok
  end

  test "checkout process" do
    customer = %{first_name: "mithereal", last_name: "nil", email: "mithereal@gmail.com", phone: "1234567"}
    items = [{"sku-123", 11.00}, {"sku-123-456", 15.00}]
    adjustments = []
    transaction = %Transaction{data: %{id: 12345, response: "JSON"}}

    {:ok, pid} = ExCheckout.new()

    Checkout.customer(pid, customer)
    Checkout.items(pid, items)
    Checkout.adjustments(pid, adjustments)
    Checkout.scan_items(pid)

    _subtotal = Checkout.subtotal(pid)

    total = Checkout.total(pid)

    _invoice = Checkout.invoice(pid)

    _state = Checkout.payment_transaction(pid, transaction)
   _receipt = Checkout.receipt(pid)

    assert total == 0
  end
end
