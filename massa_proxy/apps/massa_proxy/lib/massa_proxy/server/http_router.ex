defmodule MassaProxy.Server.HttpRouter do
  @moduledoc false
  use GenServer
  require Logger

  # Server API
  def child_spec(state) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [state]}
    }
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  def handle_call({:routing, request}, _from, state) do
    response = request
    {:reply, response, state}
  end

  # Client API
  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def routing(request) do
    GenServer.call(__MODULE__, {:routing, request})
  end
end
