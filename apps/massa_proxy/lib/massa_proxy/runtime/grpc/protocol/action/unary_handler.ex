defmodule MassaProxy.Runtime.Grpc.Protocol.Action.Unary.Handler do
  @moduledoc """
  This module is responsible for handling unary requests of the Action protocol
  """
  require Logger
  alias MassaProxy.Runtime.Grpc.Protocol.Action.Protocol, as: ActionProtocol
  alias MassaProxy.Runtime.Middleware

  def handle_unary(ctx) do
    response =
      with message <- ActionProtocol.build_msg(ctx),
           {:ok, response} <- Middleware.unary(ctx, message) do
        ActionProtocol.decode(ctx, response)
      else
        {:error, reason} -> {:error, "Failure to make unary request #{inspect(reason)}"}
      end

    Logger.debug(fn -> "User function response #{inspect(response)}" end)

    response
  end
end
