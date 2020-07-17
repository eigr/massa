defmodule MongooseProxy do
  @moduledoc """
  Documentation for `MongooseProxy`.
  """

  @doc """
  Launch Proxy Application.

  ## Examples

      iex> MongooseProxy.launch

  """
  def launch do
    port = Application.get_env(:mongoose_proxy, :user_function_port)
    {:ok, channel} = GRPC.Stub.connect("localhost:#{port}")
    DiscoveryManager.discover(channel)
  end
end
