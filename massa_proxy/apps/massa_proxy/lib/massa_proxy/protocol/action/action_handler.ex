defmodule MassaProxy.Protocol.Action.Handler do
  @doc """
  This handler is responsible for handling the Action protocol's gRPC requests.
  The Action protocol reflects the gRPC protocol in a 1: 1 manner,
  so it is necessary to identify in the payload the type of request
  that is arriving to decide how to forward messages via the protocol to the user's function
  """
  require Logger
  alias GRPC.Server
  alias Google.Protobuf.Any
  alias Cloudstate.{Action.ActionCommand, Metadata}
  alias Cloudstate.Action.ActionProtocol.Stub, as: ActionClient
  alias MassaProxy.Protocol.Action.Unary.Handler, as: UnaryHandler

  @behaviour MassaProxy.Protocol.Handler

  @impl true
  def handle(%{request_type: request_type} = payload) do
    case request_type do
      "unary" -> UnaryHandler.handle_unary(payload)
      "stream_in" -> handle_stream_in(payload)
      "stream_out" -> handle_stream_out(payload)
      "streamed" -> handle_streamed(payload)
    end
  end

  defp handle_streamed(
         %{
           stream: stream,
           input_type: input_type,
           output_type: output_type
         } = payload
       ) do
    Enum.each(stream, fn msg ->
      Logger.info("Decode request from #{inspect(msg)}")
      handle_streamed_message(stream, msg)
    end)
  end

  defp handle_stream_in(payload) do
  end

  defp handle_stream_out(payload) do
  end

  defp handle_streamed_message(stream, message) do
    # Forward via protocol to the user function, handle the response,
    # handle the forwards and side effects, and then return a valid response to the user

    # 1. Do something

    # 2. Handle forward and Side effects

    # 3. Send response to the caller
    Server.send_reply(
      stream,
      Any.new()
    )
  end
end
