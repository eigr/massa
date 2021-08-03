defmodule MassaProxy.Runtime do
  @moduledoc """

  """

  @callback init(any()) :: :ok | {:error, any(), String.t()}

  @callback discover(Cloudstate.ProxyInfo.t()) :: Cloudstate.EntitySpec.t()

  @callback report_error(Cloudstate.UserFunctionError.t()) :: any()

  @callback forward(any()) :: any()
end
