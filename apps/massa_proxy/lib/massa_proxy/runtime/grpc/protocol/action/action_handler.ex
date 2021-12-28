defmodule MassaProxy.Runtime.Grpc.Protocol.Action.Handler do
  @moduledoc """
  This handler is responsible for handling the Action protocol's gRPC requests.
  The Action protocol reflects the gRPC protocol in a 1:1 manner,
  so it is necessary to identify in the payload the type of request
  that is arriving to decide how to forward messages via the protocol to the user's function
  """
  require Logger

  alias MassaProxy.Runtime.Grpc.Protocol.Action.Unary.Handler, as: UnaryHandler
  alias MassaProxy.Runtime.Grpc.Protocol.Action.Stream.Handler, as: StreamHandler

  @behaviour MassaProxy.Protocol.Handler

  @impl true
  def handle(%{request_type: request_type} = payload) do
    case request_type do
      "unary" -> UnaryHandler.handle_unary(payload)
      "stream_in" -> StreamHandler.handle_stream_in(payload)
      "stream_out" -> StreamHandler.handle_stream_out(payload)
      "streamed" -> StreamHandler.handle_streamed(payload)
    end
  end
end
