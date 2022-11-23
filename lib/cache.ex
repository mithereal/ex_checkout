defmodule ExCheckout.Cache do
  alias ExCheckout.Registry, as: REGISTRY

  def register(name) do
    REGISTRY.register(name)
  end

  def checkout(name) do
    via_tuple(name)
  end

  def remove_checkout(name) do
    REGISTRY.unregister(name)
  end

  def via_tuple(name, registry \\ @registry_name) do
    {:via, Registry, {registry, name}}
  end
end
