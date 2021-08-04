defmodule MassaProxy.Runtime.Grpc do
  @moduledoc """
  gRPC basead Runtime.
  """
  @behaviour MassaProxy.Runtime

  @impl true
  defdelegate discover(message),
    to: MassaProxy.Protocol.Discovery.Manager,
    as: :discover

  @impl true
  defdelegate forward(payload),
    to: MassaProxy.Server.Dispatcher,
    as: :dispatch
end
