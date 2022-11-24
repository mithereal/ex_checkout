defmodule ExCheckout.Server do
  use GenServer

  alias ExCheckout.Product
  alias ExCheckout.Customer
  alias ExCheckout.Address
  alias ExCheckout.Adjustment
  alias ExCheckout.Invoice
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
    [repo] = Application.get_env(:ex_checkout, :ecto_repos)

    products =
      Enum.map(cart.items, fn {x, _} ->
        repo.get_by(Product, x, :sku)
      end)

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
      products: products,
      adjustments: adjustments
    }

    {:ok, initial_state}
  end

  @impl true
  def handle_call({:items, data}, _, state) do
    state = %{state | items: data}
    {:reply, state, state}
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
  def handle_call({:transaction, data}, _, state) do
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
    [repo] = Application.get_env(:ex_checkout, :ecto_repos)

    products =
      Enum.map(state.items, fn {x, _} ->
        repo.get_by(Product, x, :sku)
      end)

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
  def handle_call({:shipping_quote, {shipment, carriers}}, _, state) do
    [shipping_module] = Application.get_env(:ex_checkout, :shipping_module, :not_found)
      rates = case shipping_module do
      :not_found -> :not_found
      _->
        origin = shipping_module.Address.new(%{
          name: "Earl G",
          phone: "123-123-1234",
          address: "9999 Hobby Lane",
          address_line_2: nil,
          city: "Austin",
          state: "TX",
          postal_code: "78703"
        })

        destination = shipping_module.Address.new(%{
          name: "Bar Baz",
          phone: "123-123-1234",
          address: "1234 Foo Blvd",
          address_line_2: nil,
          city: "Plano",
          state: "TX",
          postal_code: "75074",
          country: "US" # optional
        })

        # Create a package. Currently only inches and pounds (lbs) supported.
        package = shipping_module.Package.new(%{
          length: 8,
          width: 8,
          height: 4,
          weight: 5,
          description: "Headphones",
          monetary_value: 20 # optional
        })
        {:ok, origin} = origin
        {:ok, destination} = destination

        # Link the origin, destination, and package with a shipment.
        shipment = shipping_module.Shipment.new(origin, destination, package)

        {:ok, shipment} = shipment


        # Fetch rates to present to the user.
        rates = shipping_module.fetch_rates(shipment, carriers: :usps)
        shipping_module.fetch_rates(shipment, carriers)
    end

    {:reply, rates, state}
  end


  @impl true
  def handle_call({:create_transaction, {shipment, service}}, _, state) do
    [shipping_module] = Application.get_env(:ex_checkout, :shipping_module, :not_found)
    transaction = case shipping_module do
      :not_found -> :not_found
      _-> shipping_module.create_transaction(shipment, service)
    end

    {:reply, transaction, state}
  end

  @impl true
  def handle_call({:subtotal}, _, state) do
    {:reply, state.sub_total, state}
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
    [repo] = Application.get_env(:ex_checkout, :ecto_repos)

    products =
      Enum.map(data.items, fn x ->
        repo.get_by(Product, x.sku, :sku)
      end)

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

  def transaction(pid, data) do
    GenServer.call(pid, {:transaction, data})
  end

  def receipt(pid) do
    GenServer.call(pid, {:receipt})
  end

  def scan_items(pid) do
    GenServer.call(pid, {:scan_items})
  end

  def shipping_quote(pid, data) do
    # shipping_address
    ## pack into boxes
    GenServer.call(pid, {:shipping_quote, data})
  end

  def apply_adjustments(pid) do
    GenServer.call(pid, {:apply_adjustments})
  end
end
