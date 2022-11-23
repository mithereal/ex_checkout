defmodule ExCheckout.Server do
  use GenServer

  alias ExCheckout.Repo
  alias ExCheckout.Product
  alias ExCheckout.Customer
  alias ExCheckout.Address
  alias ExCheckout.Adjustment
  alias ExCheckout.Invoice
  alias ExCheckout.Receipt

  defstruct sub_total: 0,
            total: 0,
            items: [],
            adjustments: [],
            products: [],
            customer: %Customer{},
            addresses: [],
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

  def start_link([cart]) do
    GenServer.start_link(__MODULE__, cart)
  end

  @impl true
  def init(cart) do
    products =
      Enum.map(cart.items, fn x ->
        Repo.get_by(Product, x.sku, :sku)
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
  def handle_call({:items, items}, _, state) do
    state = %{state | items: items}
    {:reply, state, state}
  end

  @impl true
  def handle_call({:customer, customer}, _, state) do
    state = %{state | customer: customer}
    {:reply, state, state}
  end

  @impl true
  def handle_call({:adjustments, adjustments}, _, state) do
    adjustments =
      Enum.filter(adjustments, fn x ->
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
  def handle_call({:addresses, addresses}, _, state) do
    addresses =
      Enum.map(addresses, fn x ->
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
    if is_nil(dataset) do
      dataset = Application.get_env(:ex_checkout, :adjustments, [])
    end

    Enum.member?(dataset, adjustment)
  end

  def cart(pid, data) do
    products =
      Enum.map(data.items, fn x ->
        Repo.get_by(Product, x.sku, :sku)
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

  def customer(pid, data) do
    GenServer.call(pid, {:customer, data})
  end

  def address(pid, data) do
    GenServer.call(pid, {:address, data})
  end
end
