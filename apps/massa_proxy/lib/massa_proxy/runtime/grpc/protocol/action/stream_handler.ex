defmodule MassaProxy.Runtime.Grpc.Protocol.Action.Stream.Handler do
  @moduledoc """
  This module is responsible for handling stream requests of the Action protocol
  """

  alias Google.Protobuf.Any
  alias Cloudstate.{Action.ActionCommand, Metadata}
  alias Cloudstate.Action.ActionProtocol.Stub, as: ActionClient

  import MassaProxy.Util, only: [get_connection: 0, get_type_url: 1]

  def handle_streamed(%{stream: stream, message: message} = payload) do
    messages = build_stream(message, payload)

    with {:ok, conn} <- get_connection(),
         client_stream = ActionClient.handle_streamed(conn),
         :ok <- client_stream |> run_stream(messages) |> Stream.run(),
         {:ok, consumer_stream} <- GRPC.Stub.recv(client_stream) do
      consumer_stream
      |> Stream.each(fn {:ok, r} -> GRPC.Server.send_reply(stream, unpack_response(r)) end)
      |> Stream.run()
    else
      {:error, _reason} = err -> err
    end
  end

  def handle_stream_in(%{message: message} = payload) do
    messages = build_stream(message, payload)

    with {:ok, conn} <- get_connection(),
         client_stream = ActionClient.handle_streamed_in(conn),
         task_result <- run_stream(client_stream, messages),
         :ok <- accumlate_stream_result(task_result),
         {:ok, response} <- GRPC.Stub.recv(client_stream) do
      unpack_response(response)
    else
      {:error, _reason} = err -> err
    end
  end

  def handle_stream_out(%{stream: stream} = payload) do
    message =
      ActionCommand.new(
        service_name: payload.service_name,
        name: payload.original_method,
        payload:
          Any.new(
            type_url: get_type_url(payload.input_type),
            value: payload.input_type.encode(payload.message)
          ),
        metadata: Metadata.new()
      )

    with {:ok, conn} <- get_connection(),
         {:ok, client_stream} <- ActionClient.handle_streamed_out(conn, message, []) do
      Stream.each(client_stream, fn {:ok, response} ->
        GRPC.Server.send_reply(stream, unpack_response(response))
      end)
      |> Stream.run()
    end
  end

  defp run_stream(client_stream, messages) do
    Stream.map(messages, &send_stream_msg(client_stream, &1))
  end

  defp unpack_response(%{response: {_, response}}), do: response

  defp accumlate_stream_result(results) do
    Enum.reduce_while(results, :ok, fn
      {:error, _reason} = err, _acc -> {:halt, err}
      _, acc -> {:cont, acc}
    end)
  end

  defp build_stream(msgs, state) do
    # Need to signal end_of_stream so attach a token to
    # end of the stream so that we can call `GRPC.Stub.end_stream`
    msgs
    |> Stream.concat([:halt])
    |> Stream.transform({:pre_send, state}, &transform/2)
  end

  defp transform(:halt, _acc) do
    {[:halt], :halt}
  end

  defp transform(_msg, {:pre_send, state}) do
    command =
      ActionCommand.new(
        service_name: state.service_name,
        name: state.original_method,
        payload: nil,
        metadata: Metadata.new()
      )

    {[command], {:sending, state}}
  end

  defp transform(msg, {:sending, state} = acc) do
    {[build_msg(msg, state)], acc}
  end

  defp build_msg(msg, %{input_type: input_type}) do
    ActionCommand.new(
      payload:
        Any.new(
          type_url: get_type_url(input_type),
          value: input_type.encode(msg)
        )
    )
  end

  defp send_stream_msg(client_stream, :halt) do
    GRPC.Stub.end_stream(client_stream)
  end

  defp send_stream_msg(client_stream, msg) do
    GRPC.Stub.send_request(client_stream, msg, [])
  end
end
