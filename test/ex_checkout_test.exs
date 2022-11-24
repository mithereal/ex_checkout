defmodule ExCheckoutTest do
  use ExUnit.Case
  # doctest ExCheckout
  alias ExCheckout.Server, as: Checkout

  test "init" do
    assert ExCheckout.init() == :ok
  end

  test "checkout process" do
    {:ok, pid} = ExCheckout.new()
    customer = []
    items = [{"sku-123", 11.00}, {"sku-123-456", 15.00}]
    Checkout.customer(pid, customer)
    Checkout.items(pid, items)
    Checkout.adjustments(pid, [])
    Checkout.scan_items(pid)
    Checkout.subtotal(pid)
    Checkout.apply_adjustments(pid)
    _invoice = Checkout.invoice(pid)
    _state = Checkout.transaction(pid, [])
    total = Checkout.total(pid)
    _receipt = Checkout.receipt(pid)
    assert total == 0
  end
end
