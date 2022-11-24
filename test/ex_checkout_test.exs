defmodule ExCheckoutTest do
  use ExUnit.Case
  # doctest ExCheckout

  test "init" do
    assert ExCheckout.init() == :ok
  end

  test "checkout process" do
    {:ok, pid} = ExCheckout.new()
    items = [{"sku-123", 11.00}, {"sku-123-456", 15.00}]
    ExCheckout.Server.items(pid, items)
    ExCheckout.Server.adjustments(pid, [])
    ExCheckout.Server.scan_items(pid)
    ExCheckout.Server.subtotal(pid)
    ExCheckout.Server.apply_adjustments(pid)
    _invoice = ExCheckout.Server.invoice(pid)
    state = ExCheckout.Server.transaction(pid, [])
    total = ExCheckout.Server.total(pid)
    _receipt = ExCheckout.Server.receipt(pid)
    assert total == 0
  end
end
