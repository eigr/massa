defmodule MassaProxy.Orchestrator do
  @moduledoc false
  use GenServer
  use Injectx
  require Logger

  inject(MassaProxy.Runtime)

  @protocol_minor_version 1
  @proxy_name "massa-proxy"
  @supported_entity_types [
    "cloudstate.action.ActionProtocol",
    "cloudstate.eventsourced.EventSourced"
  ]

  def child_spec(opts \\ []) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @doc """
  GenServer.init/1 callback
  """
  def init(state) do
    Runtime.init(state)
    schedule_work(50)
    {:ok, state}
  end

  def handle_info(:work, state) do
    message =
      Cloudstate.ProxyInfo.new(
        protocol_major_version: @protocol_minor_version,
        protocol_minor_version: @protocol_minor_version,
        proxy_name: @proxy_name,
        proxy_version: Application.spec(:massa_proxy, :vsn),
        supported_entity_types: @supported_entity_types
      )

    Runtime.discover(message)
    schedule_work(get_heartbeat_interval())

    {:noreply, state, :hibernate}
  end

  defp schedule_work(time), do: Process.send_after(self(), :work, time)

  defp get_heartbeat_interval(),
    do: Application.get_env(:massa_proxy, :heartbeat_interval, 60_000)
end
