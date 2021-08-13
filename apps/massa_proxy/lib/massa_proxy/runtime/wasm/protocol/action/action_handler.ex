defmodule MassaProxy.Runtime.Wasm.Protocol.Action.Handler do
  @moduledoc """
  This handler is responsible for handling the Action protocol's gRPC requests.
  The Action protocol reflects the gRPC protocol in a 1:1 manner,
  so it is necessary to identify in the payload the type of request
  that is arriving to decide how to forward messages via the protocol to the user's function
  """
  require Logger

  @behaviour MassaProxy.Protocol.Handler

  @impl true
  def handle(%{request_type: request_type} = payload) do
  end
end
