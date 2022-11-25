# ExCheckout

**A general store checkout system**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_checkout` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_checkout, "~> 0.1.0"}
  ]
end
```

## Example implementation

```elixir
defp function do
  alias ExCheckout.Server, as: Checkout
  alias ExCheckout.Transaction

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

    #incoming data from payment provider
    _state = Checkout.payment_transaction(pid, transaction)
   receipt = Checkout.receipt(pid)
   
  {:ok, receipt}
end
   ```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ex_checkout>.

