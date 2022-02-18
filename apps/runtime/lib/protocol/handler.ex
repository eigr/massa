defmodule Runtime.Protocol.Handler do
  @moduledoc """
  This Behavior must be implemented by each entity protocol to handle
  requests.

  Requests will be forwarded without the expectation of a return to the dispatcher
  because the stream will be forwarded to the implementation of this Behavior,
  leaving it to the handling and forwarding of an appropriate response to the caller
  """

  @callback handle(payload :: term) :: {:ok} | {:error, reason :: term}
end
