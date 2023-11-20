# ExCheckout

**A general store checkout system**

[![Coverage Status](https://coveralls.io/repos/github/mithereal/ex_checkout/badge.svg?branch=main)](https://coveralls.io/github/mithereal/ex_checkout?branch=main)
![CircleCI](https://img.shields.io/circleci/build/github/mithereal/ex_checkout)
[![Version](https://img.shields.io/hexpm/v/ex_checkout.svg?style=flat-square)](https://hex.pm/packages/ex_checkout)
![GitHub](https://img.shields.io/github/license/mithereal/ex_checkout)
![GitHub last commit (branch)](https://img.shields.io/github/last-commit/mithereal/ex_checkout/main)


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_checkout` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_checkout, ">= 0.0.0"}
  ]
end
```

## Example implementation

```elixir
defmodule Web.Checkout.Controller do

defp checkout(conn, {customer, items}) do
  alias ExCheckout.Server, as: Checkout
  alias ExCheckout.Transaction
  alias ExCheckout.Transaction.MyPaymentProvider, as: MyPaymentProvider
  
    customer = %{first_name: "mithereal", last_name: "nil", email: "mithereal@gmail.com", phone: "1234567"}
    items = [{"sku-123", 11.00}, {"sku-123-456", 15.00}]

    adjustments = []

    {:ok, pid} = ExCheckout.new()
   ## {:ok, pid} = ExCheckout.Cache.new("my_checkout")
   ## {pid, value} = ExCheckout.Cache.lookup("my_checkout")

    Checkout.customer(pid, customer)
    Checkout.items(pid, items)
    Checkout.adjustments(pid, adjustments)
    Checkout.scan_items(pid)

    _subtotal = Checkout.subtotal(pid)

    total = Checkout.total(pid)

    _invoice = Checkout.invoice(pid)

  #select payment provider to await on the ipn data 
    Checkout.ipn(pid, MyPaymentProvider)
   
  {:ok, pid}
end
end

defmodule Web.ExCheckout.Transaction.MyPaymentProvider do
 @behaviour ExCheckout.Behaviours.Transaction
 
 @impl true
def module_id() do
  :my_payment_provider
end

def process(pid, transaction_data) do
  transaction_data = %{data: %{id: 12345, response: "JSON"}}
    _state = Checkout.payment_transaction(pid, transaction_data)
#    _state = Checkout.payment_transaction("my_checkout", transaction_data)
   receipt = Checkout.receipt(pid)
   ## maybe write to db or socket
    {:ok, receipt}
end

end

   ```

## Custom Shipping Modules
there are 2 ways of setting up your own shipping module either specifying it in the config if its in its own namespace or
creating a module in your project with following module naming conventions 
```elixir
defmodule applicationname.ExCheckout.Carrier.Modulename do
end
```
then set up the config carriers key to match the modules config() return. 
see the config, carrier/null or payment/null module for syntax examples, 

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ex_checkout>.

