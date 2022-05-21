defmodule MassaProxy.Runtime.Grpc.Protocol.Action.Handler do
  @moduledoc """
  This handler is responsible for handling the Action protocol's gRPC requests.
  The Action protocol reflects the gRPC protocol in a 1:1 manner,
  so it is necessary to identify in the payload the type of request
  that is arriving to decide how to forward messages via the protocol to the user's function
  """
  alias MassaProxy.Runtime.Grpc.Protocol.Action.Unary.Handler, as: UnaryHandler
  alias MassaProxy.Runtime.Grpc.Protocol.Action.Stream.Handler, as: StreamHandler

  @behaviour MassaProxy.Protocol.Handler

  @impl MassaProxy.Protocol.Handler
  def handle(%{request_type: "unary"} = payload),
    do: UnaryHandler.handle_unary(payload)

  def handle(%{request_type: "stream_in"} = payload),
    do: StreamHandler.handle_stream_in(payload)

  def handle(%{request_type: "stream_out"} = payload),
    do: StreamHandler.handle_stream_out(payload)

  def handle(%{request_type: "streamed"} = payload),
    do: StreamHandler.handle_streamed(payload)
end
