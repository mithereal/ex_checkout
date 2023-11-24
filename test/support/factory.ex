defmodule ExCheckout.Factory do
  use ExMachina.Ecto, repo: ExCheckout.Repo
  alias ExCheckout.Server, as: Checkout
  alias ExCheckout.Transaction
  alias ExCheckout.Transaction.MyPaymentProvider, as: MyPaymentProvider
end
