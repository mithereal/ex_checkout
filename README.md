# ExCheckout

**A general store checkout system**

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
defp function do
  alias ExCheckout.Server, as: Checkout
  alias ExCheckout.Transaction
  alias ExCheckout.Transaction.Paypal, as: Paypal

    customer = %{first_name: "mithereal", last_name: "nil", email: "mithereal@gmail.com", phone: "1234567"}
    items = [{"sku-123", 11.00}, {"sku-123-456", 15.00}]
    adjustments = []
    transaction_data = %{data: %{id: 12345, response: "JSON"}}

    {:ok, pid} = ExCheckout.new()

    Checkout.customer(pid, customer)
    Checkout.items(pid, items)
    Checkout.adjustments(pid, adjustments)
    Checkout.scan_items(pid)

    _subtotal = Checkout.subtotal(pid)

    total = Checkout.total(pid)

    _invoice = Checkout.invoice(pid)

  #select payment provider to await on the ipn data 
    Checkout.ipn(pid, Paypal)
  #incoming data from payment provider
    _state = Checkout.payment_transaction(pid, transaction_data)
   receipt = Checkout.receipt(pid)
   
  {:ok, receipt}
end
   ```

## Custom Shipping Modules
there are 2 ways of setting up your own shipping module either specifying it in the config if its in its own namespace or
creating a module in your project with following module naming conventions 
```elixir
defmodule applicationname.ExCheckout.Carrier.Modulename do
end
```
and setting up the config carriers key to match the modules config() return. 
see the config, carrier/null(shipping) or transaction(payment) module for syntax examples, 

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ex_checkout>.

