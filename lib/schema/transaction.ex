defmodule ExCheckout.Transaction do
  defstruct data: []

  def id() do
    {:ok, 0}
  end

  def process(data) do
    {:ok, data}
  end
end
