defmodule ExCheckout.Server do
  use GenServer

  alias ExCheckout.Customer
  alias ExCheckout.Address
  alias ExCheckout.Adjustment
  alias ExCheckout.Invoice
  alias ExCheckout.Package
  alias ExCheckout.Shipment
  alias ExCheckout.Receipt
  alias ExCheckout.Transaction

  defstruct sub_total: 0,
            total: 0,
            items: [],
            adjustments: [],
            products: [],
            customer: %Customer{},
            addresses: [],
            transaction: %Transaction{},
            transaction_module: %Transaction{},
            invoice: %Invoice{},
            receipt: %Receipt{}

  def child_spec(init) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [init]},
      restart: :transient,
      type: :worker
    }
  end

  def start_link() do
    GenServer.start_link(__MODULE__, nil)
  end

  def start_link([]) do
    GenServer.start_link(__MODULE__, nil)
  end

  def start_link([cart]) do
    GenServer.start_link(__MODULE__, cart)
  end

  @impl true
  def init(nil) do
    {:ok, %__MODULE__{}}
  end

  @impl true
  def init(cart) do
    adjustments =
      Enum.filter(cart.adjustments, fn x ->
        adjustment_valid(x)
      end)
      |> Enum.map(fn x ->
        %Adjustment{
          id: x.id,
          name: x.name,
          description: x.description,
          type: x.type,
          function: x.function
        }
      end)

    initial_state = %__MODULE__{
      items: cart.items,
      products: [],
      adjustments: adjustments
    }

    {:ok, initial_state}
  end

  @impl true
  def handle_call({:items, data}, _, state) do
    state = %{state | items: data}
    {:reply, state.items, state}
  end

  @impl true
  def handle_call({:customer, data}, _, state) do
    customer = struct(Customer, data)

    state = %{state | customer: customer}
    {:reply, customer, state}
  end

  @impl true
  def handle_call({:invoice}, _, state) do
    {:reply, state.invoice, state}
  end

  @impl true
  def handle_call({:payment_transaction, data}, _, state) do
    receipt = %Receipt{
      data: %{
        subtotal: state.sub_total,
        total: state.total,
        adjustments: state.adjustments,
        items: state.products,
        transaction: state.transaction
      }
    }

    state = %{state | transaction: data}
    state = %{state | receipt: receipt}

    {:reply, data, state}
  end

  @impl true
  def handle_call({:receipt}, _, state) do
    {:reply, state.receipt, state}
  end

  @impl true
  def handle_call({:scan_items}, _, state) do
    products = ExCheckout.Products.map(state)

    state = %{state | products: products}

    {:reply, products, state}
  end

  @impl true
  def handle_call({:apply_adjustments}, _, state) do
    adjustments =
      Enum.reduce(state.adjustments, 0, fn x, acc ->
        Adjustment.value(state, x) + acc
      end)

    {:reply, adjustments, state}
  end

  @impl true
  # we prolly can add config here
  def handle_call({:shipping_quote, {carriers, package}}, _, state) do
    [shipping_module] = Application.get_env(:ex_checkout, :shipping_module, :not_found)

    [origin_address] = Enum.filter(state.address, fn x -> x.type == :origin end)
    [destination_address] = Enum.filter(state.address, fn x -> x.type == :destination end)

    rates =
      case shipping_module do
        :not_found ->
          :not_found

        _ ->
          origin = Address.new(origin_address)

          destination = Address.new(destination_address)

          package = Package.new(package)

          {:ok, origin} = origin
          {:ok, destination} = destination

          shipment = Shipment.new(origin, destination, package)

          {:ok, shipment} = shipment

          shipping_module.fetch_rates(shipment, carriers)
      end

    {:reply, rates, state}
  end

  @impl true
  def handle_call({:shipping_transaction, {shipment, service}}, _, state) do
    [shipping_module] = Application.get_env(:ex_checkout, :shipping_module, :not_found)

    transaction =
      case shipping_module do
        :not_found -> :not_found
        _ -> shipping_module.create_transaction(shipment, service)
      end

    {:reply, transaction, state}
  end

  @impl true
  def handle_call({:subtotal}, _, state) do
    sub_total = Enum.map(state.products, fn x -> x.price end) |> Enum.sum()
    updated = %{state | sub_total: sub_total}
    {:reply, sub_total, updated}
  end

  @impl true
  def handle_call({:total}, _, state) do
    subtotal = state.sub_total

    adjustments =
      Enum.reduce(state.adjustments, 0, fn x, acc ->
        Adjustment.value(state, x) + acc
      end)

    total = subtotal + adjustments

    invoice = %Invoice{
      data: %{subtotal: subtotal, total: total, adjustments: adjustments, items: state.products}
    }

    state = %{state | total: total}
    state = %{state | invoice: invoice}

    {:reply, state.total, state}
  end

  @impl true
  def handle_call({:adjustments, data}, _, state) do
    adjustments =
      Enum.filter(data, fn x ->
        adjustment_valid(%{name: x.name, type: x.type})
      end)
      |> Enum.map(fn x ->
        %Adjustment{
          id: x.id,
          name: x.name,
          description: x.description,
          type: x.type,
          function: x.function
        }
      end)

    state = %{state | adjustments: adjustments}
    {:reply, state, state}
  end

  @impl true
  def handle_call({:addresses, data}, _, state) do
    addresses =
      Enum.map(data, fn x ->
        %Address{
          address: x.address,
          type: x.type
        }
      end)

    state = %{state | addresses: addresses}
    {:reply, state, state}
  end

  @impl true
  def handle_call({:transaction_module, transaction_module}, _, state) do
    state =
      case ExCheckout.Transaction.module_exists(transaction_module) do
        true -> %{state | transaction_module: transaction_module}
        false -> state
      end

    {:reply, state, state}
  end

  @impl true
  def handle_call({:incoming_message, incoming_message}, _, state) do
    handler = state.transaction_module
    data = handler.process(incoming_message)
    payment_transaction(self(), data)
    {:reply, incoming_message, state}
  end

  @impl true
  def handle_call({:state}, _, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:cart, products, adjustments}, _, state) do
    state = %{state | products: products}
    state = %{state | adjustments: adjustments}

    {:reply, state, state}
  end

  defp adjustment_valid(adjustment, dataset \\ nil) do
    dataset =
      case(is_nil(dataset)) do
        true -> Application.get_env(:ex_checkout, :adjustments, [])
        false -> dataset
      end

    Enum.member?(dataset, adjustment)
  end

  def cart(pid, data) do
    products = ExCheckout.Products.products(data)

    adjustments =
      Enum.filter(data.adjustments, fn x ->
        adjustment_valid(%{name: x.name, type: x.type})
      end)

    GenServer.call(pid, {:cart, products, adjustments})
  end

  def state(pid) do
    GenServer.call(pid, {:state})
  end

  def subtotal(pid) do
    GenServer.call(pid, {:subtotal})
  end

  def total(pid) do
    GenServer.call(pid, {:total})
  end

  def customer(pid, data) do
    GenServer.call(pid, {:customer, data})
  end

  def address(pid, data) do
    GenServer.call(pid, {:address, data})
  end

  def items(pid, data) do
    GenServer.call(pid, {:items, data})
  end

  def adjustments(pid, data) do
    GenServer.call(pid, {:adjustments, data})
  end

  def invoice(pid) do
    GenServer.call(pid, {:invoice})
  end

  def shipping_transaction(pid, data) do
    GenServer.call(pid, {:shipping_transaction, data})
  end

  def payment_transaction(pid, data) do
    GenServer.call(pid, {:payment_transaction, data})
  end

  def receipt(pid) do
    GenServer.call(pid, {:receipt})
  end

  def scan_items(pid) do
    GenServer.call(pid, {:scan_items})
  end

  def shipping_quote(pid, data) do
    GenServer.call(pid, {:shipping_quote, data})
  end

  def apply_adjustments(pid) do
    GenServer.call(pid, {:apply_adjustments})
  end

  def isn(pid, type) do
    GenServer.call(pid, {:isn_module, type})
  end

  def ipn(pid, type) do
    GenServer.call(pid, {:transaction_module, type})
  end

  def ipn_message(pid, message) do
    GenServer.call(pid, {:incoming_message, message})
  end

  def isn_message(pid, message) do
    GenServer.call(pid, {:incoming_message, message})
  end
end
