defmodule MassaProxy.Protocol.Action.Stream.Handler do
  require Logger

  defp handle_streamed(
         %{
           stream: stream,
           input_type: input_type,
           output_type: output_type
         } = payload
       ) do
    Enum.each(stream, fn msg ->
      Logger.info("Decode request from #{inspect(msg)}")
      handle_streamed_message(stream, msg)
    end)
  end

  defp handle_stream_in(payload) do
  end

  defp handle_stream_out(payload) do
  end

  defp handle_streamed_message(stream, message) do
    # Forward via protocol to the user function, handle the response,
    # handle the forwards and side effects, and then return a valid response to the user

    # 1. Do something

    # 2. Handle forward and Side effects

    # 3. Send response to the caller
    Server.send_reply(
      stream,
      Any.new()
    )
  end
end
