defmodule ExCheckoutTest do
  use ExUnit.Case
  doctest ExCheckout

  test "init" do
    assert ExCheckout.init() == :ok
  end

  test "checkout process" do
    {:ok, pid} = ExCheckout.new()
    items = [{"sku-123", 11.00}, {"sku-123-456", 15.00}]
    state = ExCheckout.Server.items(pid, items)
    _state = ExCheckout.Server.adjustments(pid, [])
    _state = ExCheckout.Server.scan_items(pid)
    _state = ExCheckout.Server.apply_adjustments(pid)
    _invoice = ExCheckout.Server.invoice(pid)
    _state = ExCheckout.Server.transaction(pid, [])
    receipt = ExCheckout.Server.receipt(pid)

    assert ExCheckout.init() == :ok
    assert Enum.count(state.items) == 2
    assert receipt.total == 0
  end
end
