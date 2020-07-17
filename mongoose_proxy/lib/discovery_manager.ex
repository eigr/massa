defmodule DiscoveryManager do
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
    |> handle_discover_response
  end

  def report_error(channel, error) do
    {ok, response} =
      channel
      |> Cloudstate.EntityDiscovery.Stub.report_error(error)

    IO.puts("User function report error reply #{inspect(response)}")
  end

  defp handle_discover_response(response) do
    IO.puts("Received EntitySpec from user function with info: #{inspect(response)}")
  end
end
