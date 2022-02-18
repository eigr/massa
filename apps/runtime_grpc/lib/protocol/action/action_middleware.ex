defmodule Runtime.GRPC.Protocol.Action.Middleware do
  use Runtime.Protocol.Middleware, command_processor: Runtime.Protocol.Action.Processor

  alias Cloudstate.Action.ActionProtocol.Stub, as: ActionClient
  alias Runtime.GRPC.Protocol.Action.Protocol, as: ActionProtocol
  alias Runtime.Util

  @impl true
  def do_init(state), do: {:ok, state}

  @impl true
  def handle_effect(context) do
    with message <- ActionProtocol.build_msg(context),
         {:ok, channel} <- Util.get_connection(),
         {:ok, commands} <- ActionClient.handle_unary(channel, message) do
      {:ok, commands}
    else
      {:error, reason} ->
        {:error, {:error, "Failure to make side effect request #{inspect(reason)}"}}
    end
  end

  @impl true
  def handle_forward(_context, _message) do
    raise "Not implemented"
  end

  @impl true
  def handle_unary(_context, message) do
    with {:ok, channel} <- Util.get_connection(),
         {:ok, command} <- ActionClient.handle_unary(channel, message) do
      {:ok, command}
    else
      {:error, reason} -> {:error, "Failure to make unary request #{inspect(reason)}"}
    end
  end

  @impl true
  def handle_streamed(_context, messages) do
    with {:ok, channel} <- Util.get_connection(),
         client_stream = ActionClient.handle_streamed(channel),
         :ok <- run_stream(client_stream, messages) |> Stream.run(),
         {:ok, consumer_stream} <- GRPC.Stub.recv(client_stream) do
      {:ok, Enum.to_list(consumer_stream)}
    else
      {:error, reason} -> {:error, "Failure to make streamed request #{inspect(reason)}"}
    end
  end

  @impl true
  def handle_stream_in(_context, _messages) do
    raise "Not implemented"
  end

  @impl true
  def handle_stream_out(_context, _message) do
    raise "Not implemented"
  end

  defp run_stream(client_stream, messages) do
    messages
    |> Stream.map(&send_stream_msg(client_stream, &1))
  end

  defp send_stream_msg(client_stream, :halt) do
    GRPC.Stub.end_stream(client_stream)
  end

  defp send_stream_msg(client_stream, msg) do
    GRPC.Stub.send_request(client_stream, msg, [])
  end
end
