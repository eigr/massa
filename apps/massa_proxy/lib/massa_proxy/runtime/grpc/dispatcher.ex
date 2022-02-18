defmodule MassaProxy.Runtime.Grpc.Server.Dispatcher do
  @moduledoc """
  This module is the entrypoint of all gRPC requests for all protocols
  """
  require Logger
  alias MassaProxy.Runtime.Grpc.Protocol.Action.Handler, as: ActionHandler
  alias MassaProxy.Runtime.Grpc.Protocol.EventSourced.Handler, as: EventSourcedHandler
  alias MassaProxy.Runtime.MiddlewareSupervisor

  def dispatch(
        %{
          entity_type: entity_type,
          persistence_id: persistence_id,
          message: message,
          stream: stream
        } = payload
      ) do
    Logger.info(
      "Handle request for entity type #{inspect(entity_type)}. Message: #{inspect(message)}"
    )

    Logger.debug(
      "Handle stream: #{inspect(stream)}. With persistence id: #{inspect(persistence_id)}"
    )

    with {:ok, pid} <- MiddlewareSupervisor.start_middleware(payload) do
      Logger.debug("Started middleware with pid: #{inspect(pid)}")

      case entity_type do
        "cloudstate.action.ActionProtocol" -> ActionHandler.handle(payload)
        "cloudstate.eventsourced.EventSourced" -> EventSourcedHandler.handle(payload)
        _ -> Logger.error("Not Implemented Entity type #{entity_type}")
      end
    else
      error -> Logger.error("Middleware error #{inspect(error)}")
    end
  end
end
