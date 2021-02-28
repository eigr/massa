defmodule EventSourced.Router do
  use GenServer

  def init(state) do
    {:ok, state}
  end

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end
end
