defmodule ExCheckout.Server do
  use GenServer

  alias ExCheckout.Repo
  alias ExCheckout.Product
  #  alias ExCheckout.Account
  #  alias ExCheckout.Address
  #  alias ExCheckout.Adjustment
  #  alias ExCheckout.Invoice

  defstruct items: [],
            adjustments: [],
            products: [],
            account: nil,
            addresses: [],
            sub_total: 0,
            total: 0,
            invoice: nil

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
    items =
      Enum.map(cart.items, fn x ->
        Repo.get_by(Product, x.sku, :sku)
      end)

    adjustments =
      Enum.filter(cart.adjustments, fn x ->
        adjustment_valid(x)
      end)

    initial_state = %__MODULE__{
      items: items,
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
  def handle_call({:account, account}, _, state) do
    state = %{state | account: account}
    {:reply, state, state}
  end

  @impl true
  def handle_call({:adjustments, adjustments}, _, state) do
    adjustments =
      Enum.filter(adjustments, fn x ->
        adjustment_valid(x)
      end)

    state = %{state | adjustments: adjustments}
    {:reply, state, state}
  end

  @impl true
  def handle_call({:addresses, addresses}, _, state) do
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

  defp adjustment_valid(_data) do
    true
  end

  def cart(pid, data) do
    products =
      Enum.map(data.items, fn x ->
        Repo.get_by(Product, x.sku, :sku)
      end)

    adjustments =
      Enum.filter(data.adjustments, fn x ->
        adjustment_valid(x)
      end)

    GenServer.call(pid, {:cart, products, adjustments})
  end

  def state(pid) do
    GenServer.call(pid, {:state})
  end

  def account(pid, data) do
    GenServer.call(pid, {:account, data})
  end

  def address(pid, data) do
    GenServer.call(pid, {:address, data})
  end
end
