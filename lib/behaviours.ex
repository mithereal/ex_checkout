defmodule ExCheckout.Behaviours do
  defmodule Transaction do
    @callback module_id() :: any
  end

  defmodule Carrier do
    @callback carrier() :: any
  end
end
