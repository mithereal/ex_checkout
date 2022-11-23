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
end
