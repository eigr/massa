defmodule MassaProxy.Infra.Cache do
  @moduledoc """
  This is a very simple basic cache mechanism for items of any kind.
  It has no key expiration strategy so the client code must be concerned
  with the expiration logic of the items added to this Cache.
  """
  use GenServer
  require Logger

  # Public API
  def start_link(state), do: GenServer.start_link(__MODULE__, state, name: via_tuple(get_cachename(state)))

  def eviction(cache_name, key), do: GenServer.cast(via_tuple(cache_name), {:eviction, key})

  def get(cache_name, key), do: GenServer.call(via_tuple(cache_name), {:get, key})

  def put(cache_name, key, value), do: GenServer.cast(via_tuple(cache_name), {:put, key, value})

  # Internal API
  @impl true
  def init(state) do
    cache_name = get_cachename(state)
    Logger.debug("State: #{inspect state}")
    :ets.new(cache_name, [:set, :public, :named_table])
    {:ok, state}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    cache_name = get_cachename(state)
    reply =
      case :ets.lookup(cache_name, key) do
        [] -> nil
        [{_key, value}] -> value
      end

    {:reply, reply, state}
  end

  @impl true
  def handle_cast({:eviction, key}, state) do
    cache_name = get_cachename(state)
    :ets.delete(cache_name, key)
    {:noreply, state}
  end

  @impl true
  def handle_cast({:put, key, value}, state) do
    cache_name = get_cachename(state)
    :ets.insert(cache_name, {key, value})
    {:noreply, state}
  end

  defp via_tuple(cache_name) do
    {:via, Registry, {MassaProxy.LocalRegistry, cache_name}}
  end

  defp get_cachename(state), do: Keyword.get(state, :cache_name)
end
