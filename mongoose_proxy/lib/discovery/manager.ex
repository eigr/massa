defmodule Dicovery.ManagerServer do
  use GenServer

  @doc """
  GenServer.init/1 callback
  """
  def init(_) do
    port = Application.get_env(:mongoose_proxy, :user_function_port)
    {:ok, channel} = GRPC.Stub.connect("localhost:#{port}")
    {:ok, channel}
  end

  def handle_call(:discover, _from, channel) do
    Discovery.Manager.discover(channel)
    {:reply, :ok, channel}
  end

  ### Client API

  def start_link(channel \\ []) do
    GenServer.start_link(__MODULE__, channel, name: __MODULE__)
  end

  def discover, do: GenServer.call(__MODULE__, :discover)
end

defmodule Discovery.Manager do
  require Logger

  @protocol_minor_version 1
  @protocol_major_version 0
  @proxy_name "mongoose-proxy"
  @supported_entity_types ["cloudstate.eventsourced.EventSourced"]

  def discover(channel) do
    message =
      Cloudstate.ProxyInfo.new(
        protocol_major_version: @protocol_minor_version,
        protocol_minor_version: @protocol_minor_version,
        proxy_name: @proxy_name,
        proxy_version: Application.spec(:mongoose_proxy, :vsn),
        supported_entity_types: @supported_entity_types
      )

    channel
    |> Cloudstate.EntityDiscovery.Stub.discover(message)
    |> handle_response
  end

  def report_error(channel, error) do
    {_, response} =
      channel
      |> Cloudstate.EntityDiscovery.Stub.report_error(error)

    Logger.info("User function report error reply #{inspect(response)}")
  end

  defp handle_response(response) do
    Logger.info("Received EntitySpec from user function with info: #{inspect(response)}")
  end
end
