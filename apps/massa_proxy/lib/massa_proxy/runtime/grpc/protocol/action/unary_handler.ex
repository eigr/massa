defmodule MassaProxy.Runtime.Grpc.Protocol.Action.Unary.Handler do
  @moduledoc """
  This module is responsible for handling unary requests of the Action protocol
  """
  require Logger
  alias Cloudstate.Action.ActionProtocol.Stub, as: ActionClient
  alias MassaProxy.Runtime.Grpc.Protocol.Action.Protocol, as: ActionProtocol

  import MassaProxy.Util, only: [get_connection: 0]

  def handle_unary(ctx) do
    # Call user function and return
    message = ActionProtocol.build_msg(ctx)

    response =
      with {:ok, channel} <- get_connection(),
           {:ok, response} <- ActionClient.handle_unary(channel, message) do
        ActionProtocol.decode(ctx, response)
      else
        {:error, reason} -> {:error, "Failure to make unary request #{inspect(reason)}"}
      end

    Logger.debug(fn -> "User function response #{inspect(response)}" end)

    response
  end
end
