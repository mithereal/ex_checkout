defmodule ExCheckoutTest do
  use ExUnit.Case
  doctest ExCheckout

  test "init" do
    assert ExCheckout.init() == :ok
  end
end
