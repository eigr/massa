defmodule MassProxy.Reflection.Service do
  @moduledoc """
  This module implement gRPC Reflection
  """
  @moduledoc since: "0.1.0"

  use GRPC.Server, service: Grpc.Reflection.V1alpha.ServerReflection.Service

  require Logger
  alias GRPC.Server
  alias MassaProxy.Reflection.Server, as: ReflectionServer
  alias Grpc.Reflection.V1alpha.{ServerReflectionRequest, ServerReflectionResponse, ErrorResponse}

  @spec server_reflection_info(ServerReflectionRequest.t(), GRPC.Server.Stream.t()) ::
          ServerReflectionResponse.t()
  def server_reflection_info(request, stream) do
    Stream.each(request, fn message ->
      Logger.debug("Received reflection request: #{inspect(message)}")

      case message.message_request do
        {:list_services, _} ->
          Server.send_reply(stream, ReflectionServer.list_services())

        {:file_containing_symbol, _} ->
          symbol = elem(message.message_request, 1)
          Server.send_reply(stream, ReflectionServer.find_by_symbol(symbol))

        {:file_by_filename, _} ->
          filename = elem(message.message_request, 1)
          Server.send_reply(stream, ReflectionServer.find_by_filename(filename))

        _ ->
          Logger.warn("This Reflection Operation is not supported")

          response =
            ServerReflectionResponse.new(
              message_response:
                {:error_response,
                 ErrorResponse.new(error_code: 13, error_message: "Operation not supported")}
            )

          Server.send_reply(stream, response)
      end
    end)
    |> Stream.run()
  end
end
