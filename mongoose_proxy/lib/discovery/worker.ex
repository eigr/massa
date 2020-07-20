defmodule Discovery.Worker do
  use GenServer
  require Logger

  @host Application.get_env(:mongoose_proxy, :user_function_host)
  @port Application.get_env(:mongoose_proxy, :user_function_port)
  @heartbeat_interval Application.get_env(:mongoose_proxy, :heartbeat_interval)

  @doc """
  GenServer.init/1 callback
  """
  def init(state) do
    schedule_work(1_000)
    {:ok, state}
  end

  def handle_call(:connect, _from, _) do
    {result, state} = GRPC.Stub.connect("#{@host}:#{@port}")

    case result do
      :ok -> {:reply, result, state}
      :error -> {:reply, :error, []}
    end
  end

  def handle_call(:discover, _from, state) do
    Discovery.Manager.discover(state)
    {:reply, :ok, state}
  end

  def handle_info(msg, state) do
    case msg do
      :work ->
        {result, state} = GRPC.Stub.connect("#{@host}:#{@port}")
        Discovery.Manager.discover(state)
        schedule_work(@heartbeat_interval)

        case result do
          :ok -> {:noreply, state}
          :error -> {:reply, :error, []}
        end

      _ ->
        {:noreply, state}
    end
  end

  ### Client API
  def start_link(state \\ []) do
    Logger.info("Starting #{__MODULE__}...")
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def connect, do: GenServer.call(__MODULE__, :connect)
  def discover, do: GenServer.call(__MODULE__, :discover)

  defp schedule_work(time), do: Process.send_after(self(), :work, time)
end
