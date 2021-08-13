defmodule MassaProxy.Runtime.Grpc.Protocol.Action.Unary.Handler do
  @moduledoc """
  This module is responsible for handling unary requests of the Action protocol
  """
  require Logger
  alias Google.Protobuf.Any
  alias Cloudstate.{Action.ActionCommand, Metadata}
  alias Cloudstate.Action.ActionProtocol.Stub, as: ActionClient

  import MassaProxy.Util, only: [get_connection: 0, get_type_url: 1]

  def handle_unary(payload) do
    # I think it is better to handle unary calls through Tasks, so we create a process by request
    Task.Supervisor.async(MassaProxy.TaskSupervisor, fn ->
      handle_unary_message(payload)
    end)
    |> Task.await()
    |> handle_unary_result()
  end

  defp handle_unary_message(payload) do
    # Call user function and return
    message =
      ActionCommand.new(
        service_name: payload.service_name,
        name: payload.original_method,
        payload:
          Any.new(
            type_url: get_type_url(payload.input_type),
            value: payload.input_type.encode(payload.message)
          ),
        # Create metadata
        metadata: Metadata.new()
      )

    response =
      case get_connection() do
        {:ok, channel} ->
          channel
          |> ActionClient.handle_unary(message)

        _ ->
          {:error, "Failure to make unary request"}
      end

    Logger.debug("User function response: #{inspect(response)} ")
    response
  end

  defp handle_unary_result(result) do
    # Handle forward and Side effects and Send gRPC reply message with result
    case result do
      {:ok, reply} -> handle_action_response(reply)
      {:error, reason} -> Logger.error("Failed to call user function. Reason #{inspect(reason)}")
      _ -> Logger.error("Failed to call user function. Reason Unknown")
    end
  end

  defp handle_action_response(reply) do
    handle_side_effects(reply.side_effects)

    case reply.response do
      {:reply, _} -> elem(reply.response, 1)
      {:failure, _} -> elem(reply.response, 1)
      {:forward, _} -> elem(reply.response, 1)
    end
  end

  defp handle_side_effects(side_effects) do
  end
end
