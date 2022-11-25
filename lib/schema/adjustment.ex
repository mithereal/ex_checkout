defmodule ExCheckout.Adjustment do
  @moduledoc """
  Definition of the structure of an adjustment.
  """
  defstruct id: nil, name: nil, description: nil, function: nil, type: nil

  @doc """
    Creates a structure based on:
    
    `id`  Id of the adjustment

    `name`  Name of the adjustment

    `description` Description of the adjustment

    `type` Type of the adjustment

    `function` Anonymous function to be used by `ExCheckout`

  """
  def new(name, description, function, type \\ nil, id \\ nil) do
    if(is_nil(id)) do
      id = Nanoid.generate()
    end

    %ExCheckout.Adjustment{
      id: id,
      name: name,
      description: description,
      type: type,
      function: function
    }
  end

  @doc """
    Get the Adjustment Result.
  """
  def result(
        %{items: items, adjustments: adjustments} = struct,
        name
      ) do
    adjustment = Enum.reject(adjustments, &(&1.name == name))
    adjustment_result = adjustment_result(struct, adjustment)
    {:ok, adjustment_result}
  end

  def get(
        %{adjustments: adjustments} = _struct,
        %{name: name} = _adjustment
      ) do
    adjustment = Enum.reject(adjustments, &(&1.name == name))
    {:ok, adjustment}
  end

  def value(adjustments, adjustment) do
    adjustment.function.(adjustments)
  end

  def subtotal(%{items: items}) do
    Enum.reduce(items, 0, fn x, acc -> x.qty * x.price + acc end)
  end

  defp adjustment_result(%{items: items, adjustments: adjustments} = struct, adjustment) do
    subtotal = subtotal(struct)

    adjustment_value = value(struct, adjustment)

    adjustment = Map.put(adjustment, :adjustment_value, adjustment_value)

    {:ok, %{subtotal: subtotal, adjustment: adjustment}}
  end
end
