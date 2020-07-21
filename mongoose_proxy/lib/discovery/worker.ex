defmodule Discovery.Worker do
  use GenServer
  require Logger

  @host Application.get_env(:mongoose_proxy, :user_function_host)
  @port Application.get_env(:mongoose_proxy, :user_function_port)
  @heartbeat_interval Application.get_env(:mongoose_proxy, :heartbeat_interval)
  @user_function_uds_enable Application.get_env(:mongoose_proxy, :user_function_uds_enable)
  @user_function_sock_addr Application.get_env(:mongoose_proxy, :user_function_sock_addr)

  @doc """
  GenServer.init/1 callback
  """
  def init(state) do
    schedule_work(1_000)
    {:ok, state}
  end

  def handle_call(:connect, _from, _) do
    {result, state} = get_connection

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
        {result, state} = get_connection

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
    Logger.info(
      "Starting #{__MODULE__} on target function address unix://#{
        get_address(@user_function_uds_enable)
      }"
    )

    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def connect, do: GenServer.call(__MODULE__, :connect)
  def discover, do: GenServer.call(__MODULE__, :discover)

  defp schedule_work(time), do: Process.send_after(self(), :work, time)

  defp get_address(false), do: "#{@host}:#{@port}"
  defp get_address(true), do: "#{@user_function_sock_addr}"

  defp get_connection(),
    do:
      GRPC.Stub.connect(get_address(@user_function_uds_enable), interceptors: [GRPC.Logger.Client])
end
