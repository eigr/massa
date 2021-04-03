defmodule Discovery.Worker do
  @moduledoc false
  use GenServer
  require Logger

  @doc """
  GenServer.init/1 callback
  """
  def init(state) do
    schedule_work(1_000)
    {:ok, state}
  end

  def handle_call(:connect, _from, _) do
    {result, state} = get_connection()

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
        {result, state} = get_connection()

        Discovery.Manager.discover(state)
        schedule_work(get_heartbeat_interval())

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
    Logger.info("#{startup_message(is_uds_enable?())}")
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def connect, do: GenServer.call(__MODULE__, :connect)
  def discover, do: GenServer.call(__MODULE__, :discover)

  defp schedule_work(time), do: Process.send_after(self(), :work, time)

  defp get_address("false"), do: "#{get_function_host()}:#{get_function_port()}"
  defp get_address(false), do: get_address(false)
  defp get_address("true"), do: get_address(true)
  defp get_address(true), do: "#{get_uds_address()}"

  defp startup_message(uds_enable) do
    case uds_enable do
      true ->
        "Starting #{__MODULE__} on target function address unix://#{get_address(uds_enable)}"

      _ ->
        "Starting #{__MODULE__} on target function address tcp://#{get_address(uds_enable)}"
    end
  end

  defp get_connection(),
    do: GRPC.Stub.connect(get_address(is_uds_enable?()), interceptors: [GRPC.Logger.Client])

  defp get_function_port(), do: Application.get_env(:massa_proxy, :user_function_port, 8080)

  defp get_function_host(),
    do: Application.get_env(:massa_proxy, :user_function_host, "127.0.0.1")

  defp get_heartbeat_interval(),
    do: Application.get_env(:massa_proxy, :heartbeat_interval, 60_000)

  defp is_uds_enable?(),
    do: Application.get_env(:massa_proxy, :user_function_uds_enable, false)

  defp get_uds_address(),
    do: Application.get_env(:massa_proxy, :user_function_sock_addr, "/var/run/cloudstate.sock")
end
