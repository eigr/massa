defmodule MassaProxy.Runtime.Grpc do
  @moduledoc """
  gRPC basead Runtime.
  """
  @behaviour MassaProxy.Runtime

  @impl true
  def init(state), do: :ok

  @impl true
  defdelegate discover(message),
    to: MassaProxy.Protocol.Discovery.Manager,
    as: :discover

  @impl true
  defdelegate report_error(error),
    to: MassaProxy.Protocol.Discovery.Manager,
    as: :report_error

  @impl true
  defdelegate forward(payload),
    to: MassaProxy.Server.Dispatcher,
    as: :dispatch
end
