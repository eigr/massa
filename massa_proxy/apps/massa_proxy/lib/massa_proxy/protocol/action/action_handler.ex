defmodule MassaProxy.Protocol.Action.Handler do
  @moduledoc """
  This handler is responsible for handling the Action protocol's gRPC requests.
  The Action protocol reflects the gRPC protocol in a 1:1 manner,
  so it is necessary to identify in the payload the type of request
  that is arriving to decide how to forward messages via the protocol to the user's function
  """
  require Logger
  alias GRPC.Server
  alias Google.Protobuf.Any
  alias Cloudstate.{Action.ActionCommand, Metadata}
  alias Cloudstate.Action.ActionProtocol.Stub, as: ActionClient
  alias MassaProxy.Protocol.Action.Unary.Handler, as: UnaryHandler
  alias MassaProxy.Protocol.Action.Stream.Handler, as: StreamHandler

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
