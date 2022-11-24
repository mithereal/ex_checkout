defmodule ExCheckoutTest do
  use ExUnit.Case
  doctest ExCheckout

  test "init" do
    assert ExCheckout.init() == :ok
  end


  test "checkout process" do
    assert ExCheckout.init() == :ok
    session = ExCheckout.new()
  end
end
