defmodule MassaProxy.Server.Dispatcher do
  require Logger

  def dispatch(%{
        entity_type: entity_type,
        persistence_id: persistence_id,
        message: message,
        stream: stream
      }) do
    Logger.info(
      "Handle request for entity type #{inspect(entity_type)}. Message: #{inspect(message)}"
    )

    Logger.debug(
      "Handle stream: #{inspect(stream)}. With persistence id: #{inspect(persistence_id)}"
    )
  end
end
