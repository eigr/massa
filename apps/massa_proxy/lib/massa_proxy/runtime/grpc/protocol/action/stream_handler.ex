defmodule MassaProxy.Runtime.Grpc.Protocol.Action.Stream.Handler do
  @moduledoc """
  This module is responsible for handling stream requests of the Action protocol
  """
  require Logger

  alias Cloudstate.Action.ActionProtocol.Stub, as: ActionClient
  alias Google.Protobuf.Empty
  alias MassaProxy.Runtime.Grpc.Protocol.Action.Protocol, as: ActionProtocol
  alias MassaProxy.Runtime.Middleware

  alias Runtime.Util

  def handle_streamed(%{stream: stream} = ctx) do
    with messages <- ActionProtocol.build_stream(ctx),
         {:ok, consumer_stream} <- Middleware.streamed(ctx, messages) do
      consumer_stream
      |> Stream.each(fn
        {:ok, %Cloudstate.Action.ActionResponse{response: nil}} ->
          GRPC.Server.send_reply(stream, Empty.new())

        {:ok, %Cloudstate.Action.ActionResponse{response: _response} = r} ->
          GRPC.Server.send_reply(stream, ActionProtocol.decode(ctx, r))

        {:error, _reason} = err ->
          Logger.error("Error while handling stream request: #{inspect(err)}")
          err
      end)
      |> Stream.run()
    else
      {:error, _reason} = err ->
        Logger.error("Error while handling stream request: #{inspect(err)}")
        err
    end
  end

  def handle_stream_in(ctx) do
    messages = ActionProtocol.build_stream(ctx)

    with {:ok, conn} <- Util.get_connection(),
         client_stream = ActionClient.handle_streamed_in(conn),
         task_result <- run_stream(client_stream, messages),
         :ok <- accumlate_stream_result(task_result),
         {:ok, response} <- GRPC.Stub.recv(client_stream) do
      ActionProtocol.decode(ctx, response)
    else
      {:error, _reason} = err -> err
    end
  end

  def handle_stream_out(%{stream: stream} = ctx) do
    message = ActionProtocol.build_msg(ctx, :full)

    with {:ok, conn} <- Util.get_connection(),
         {:ok, client_stream} <- ActionClient.handle_streamed_out(conn, message, []) do
      Stream.each(client_stream, fn {:ok, response} ->
        GRPC.Server.send_reply(stream, ActionProtocol.decode(ctx, response))
      end)
      |> Stream.run()
    end
  end

  defp run_stream(client_stream, messages) do
    Stream.map(messages, &send_stream_msg(client_stream, &1))
  end

  defp accumlate_stream_result(results) do
    Enum.reduce_while(results, :ok, fn
      {:error, _reason} = err, _acc -> {:halt, err}
      _, acc -> {:cont, acc}
    end)
  end

  defp send_stream_msg(client_stream, :halt) do
    GRPC.Stub.end_stream(client_stream)
  end

  defp send_stream_msg(client_stream, msg) do
    GRPC.Stub.send_request(client_stream, msg, [])
  end
end
