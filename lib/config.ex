defmodule ExCheckout.Config do
  @doc """
  Return value by key from config.exs file.
  """

  alias ExCheckout.Carrier

  def get(name, default \\ nil) do
    Application.get_env(:ex_checkout, name, default)
  end

  def repo, do: List.first(Application.fetch_env!(:ex_checkout, :ecto_repos))

  @spec config() :: Keyword.t() | none()
  def config() do
    carriers = Application.get_env(:ex_checkout, :carriers, [])
    payment_providers = Application.get_env(:ex_checkout, :payment_providers, [])

    {carriers, payment_providers}
  end

  @spec carriers() :: [Carrier.t()]
  def carriers() do
    config()
    |> Enum.map(fn {x, _} -> x end)
  end

  @spec carriers(nil) :: [Carrier.t()]
  def carriers(nil) do
    config()
    |> Enum.map(fn {x, _} -> x end)
  end

  @spec carriers(List.t()) :: [Carrier.t()]
  def carriers(config) do
    config
    |> Enum.map(fn {x, _} -> x end)
  end

  @spec payment_providers() :: [Map.t()]
  def payment_providers() do
    config()
    |> Enum.map(fn {_, x} -> x end)
  end

  @spec payment_providers() :: [Map.t()]
  def payment_providers(nil) do
    config()
    |> Enum.map(fn {x, _} -> x end)
  end

  @spec payment_providers(List.t()) :: [Map.t()]
  def payment_providers(config) do
    config
    |> Enum.map(fn {x, _} -> x end)
  end
end
