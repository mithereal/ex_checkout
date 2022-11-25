defmodule ExCheckout.Cache do
  @registry_name :ex_checkout_registry

  alias ExCheckout.Registry, as: REGISTRY

  def register(name, pid) do
    REGISTRY.register(pid, name)
  end

  def lookup(name) do
    REGISTRY.lookup(name)
  end

  def new(name) do
    via_tuple(name)
  end

  def stop(name) do
    REGISTRY.unregister(name)
  end

  def via_tuple(name, registry \\ @registry_name) do
    {:via, Registry, {registry, name}}
  end
end
