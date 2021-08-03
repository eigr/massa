defmodule MassaProxy.Runtime do
  @moduledoc """
  Runtime provides the proxy's ability to serve the Cloudstate protocol
  under different backends.
  Possible implementations can be based on the gRPC protocol
  or via Webassembly Wasm.
  """

  @doc """
  `init` is used to effectively perform any kind of initialization required by the underlying implementation.
  """
  @callback init(any()) :: :ok | {:error, any(), String.t()}

  @doc """
  `discover` what entities the user function wishes to serve.
  """
  @callback discover(Cloudstate.ProxyInfo.t()) :: Cloudstate.EntitySpec.t()

  @doc """
  `report_error` an error back to the user function. This will only be invoked to tell the user function
  that it has done something wrong, eg, violated the protocol, tried to use an entity type that
  isn't supported, or attempted to forward to an entity that doesn't exist, etc. These messages
  should be logged clearly for debugging purposes.
  """
  @callback report_error(Cloudstate.UserFunctionError.t()) :: any()

  @doc """
  `forward` can forward gRPC requests to the user role.
  Implementations of this function will usually delegate to other modules that implement the real logic.
  """
  @callback forward(any()) :: any()

  @optional_callbacks init: 1
end
