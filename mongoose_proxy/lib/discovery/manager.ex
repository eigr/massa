defmodule Discovery.Manager do
  require Logger

  @protocol_minor_version 1
  @protocol_major_version 0
  @proxy_name "mongoose-proxy"
  @supported_entity_types ["cloudstate.eventsourced.EventSourced"]

  def discover(channel) do
    message =
      Cloudstate.ProxyInfo.new(
        protocol_major_version: @protocol_minor_version,
        protocol_minor_version: @protocol_minor_version,
        proxy_name: @proxy_name,
        proxy_version: Application.spec(:mongoose_proxy, :vsn),
        supported_entity_types: @supported_entity_types
      )

    channel
    |> Cloudstate.EntityDiscovery.Stub.discover(message)
    |> handle_response
  end

  def report_error(channel, error) do
    {_, response} =
      channel
      |> Cloudstate.EntityDiscovery.Stub.report_error(error)

    Logger.info("User function report error reply #{inspect(response)}")
  end

  defp handle_response(response) do
    extract_message(response)
    |> validate
    |> register_entities
  end

  defp register_entities(message) do
    # TODO: Registry entities here
  end

  defp validate(message) do
    entities = message.entities

    if Enum.empty?(entities) do
      Logger.error("No entities were reported by the discover call!")
      raise "No entities were reported by the discover call!"
    end

    entities
    |> Enum.each(fn entity ->
      if !Enum.member?(@supported_entity_types, entity.entity_type) do
        Logger.error("This proxy not support entities of type #{entity.entity_type}")
        raise "This proxy not support entities of type #{entity.entity_type}"
      end
    end)

    if !is_binary(message.proto) do
      Logger.error("No descriptors found in EntitySpec")
      raise "No descriptors found in EntitySpec"
    end

    if String.trim(message.service_info.service_name) == "" do
      Logger.warn("Service Info does not provide a service name")
    end

    {:ok, message}
  end

  defp extract_message(response) do
    {:ok, message} = response

    case response do
      ok ->
        Logger.info("Received EntitySpec from user function with info: #{inspect(message)}")
        message

      _ ->
        Logger.error("Error -> #{inspect(response)}")
    end
  end
end
