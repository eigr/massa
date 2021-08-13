defmodule MassaProxy.Runtime.Wasm do
  @moduledoc """
  Wasm basead Runtime.
  """

  @behaviour MassaProxy.Runtime

  @impl true
  def init(state), do: :ok

  @impl true
  defdelegate discover(message),
    to: MassaProxy.Runtime.Wasm.Protocol.Discovery.Manager,
    as: :discover

  @impl true
  defdelegate report_error(error),
    to: MassaProxy.Runtime.Wasm.Protocol.Discovery.Manager,
    as: :report_error

  @impl true
  defdelegate forward(payload),
    to: MassaProxy.Runtime.Wasm.Server.Dispatcher,
    as: :dispatch
end
