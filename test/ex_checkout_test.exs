defmodule ExCheckoutTest do
  use ExUnit.Case
  # doctest ExCheckout
  alias ExCheckout.Server, as: Checkout

  test "init" do
    assert ExCheckout.init() == :ok
  end

  test "checkout process" do
    {:ok, pid} = ExCheckout.new()
    customer = %{first_name: "mithereal", last_name: "nil", email: "mithereal@gmail.com", phone: "1234567"}
    items = [{"sku-123", 11.00}, {"sku-123-456", 15.00}]
    Checkout.customer(pid, customer)
    Checkout.items(pid, items)
    Checkout.adjustments(pid, [])
    Checkout.scan_items(pid)
    Checkout.subtotal(pid)
    Checkout.apply_adjustments(pid)
    total = Checkout.total(pid)
    _invoice = Checkout.invoice(pid)
    _state = Checkout.transaction(pid, [])
    _receipt = Checkout.receipt(pid)
    assert total == 0
  end
end
