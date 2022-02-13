defmodule MassaProxy.Runtime.Middleware do
  @moduledoc """
  Middleware is a module that can be used to add functionality
  to interact with the user role and other remote middlewares.
  """
  use GenServer
  require Logger

  alias Cloudstate.Action.ActionResponse
  alias Cloudstate.Action.ActionProtocol.Stub, as: ActionClient

  import MassaProxy.Util, only: [get_connection: 0]

  @impl true
  def init(state) do
    {:ok, state}
  end

  def start_link(%{name: name} = state) do
    GenServer.start_link(__MODULE__, state, name: name)
  end

  @impl true
  def handle_call(
        {:handle_unary, %{context: context, payload: message} = _input},
        _from,
        # %{command_processor: command_processor} = state
        state
      ) do
    result =
      with {:ok, channel} <- get_connection(),
           {:ok, %ActionResponse{side_effects: effects} = commands} <-
             ActionClient.handle_unary(channel, message),
           {:ok, result} <- process_command(nil, context, commands) do
        handle_effects(effects)
        {:ok, result}
      else
        {:error, reason} -> {:error, "Failure to make unary request #{inspect(reason)}"}
      end

    Logger.debug("User function response #{inspect(result)}")

    {:reply, result, state}
  end

  @impl true
  def handle_call(
        {:handle_streamed, %{context: context, payload: messages} = _input},
        from,
        state
      ) do
    spawn(fn ->
      stream_result =
        with {:ok, conn} <- get_connection(),
             client_stream = ActionClient.handle_streamed(conn),
             :ok <- run_stream(client_stream, messages) |> Stream.run(),
             {:ok, consumer_stream} <- GRPC.Stub.recv(client_stream) do
          Logger.debug(
            "Commands: #{inspect(consumer_stream)} Client Stream: #{inspect(client_stream)}"
          )

          consumer_stream =
            consumer_stream
            |> Stream.map(fn
              {:ok, %ActionResponse{side_effects: effects} = command} ->
                Logger.debug("Consumer Stream result: #{inspect(command)}")

                result =
                  case process_command(nil, context, command) do
                    {:ok, result} ->
                      {:ok, result}

                    {:error, reason} ->
                      {:error, "Failure on process command #{inspect(reason)}"}
                  end

                handle_effects(effects)
                result

              {:error, reason} ->
                {:error, "Failure on process client stream #{inspect(reason)}"}
            end)
            |> Enum.to_list()

          {:ok, consumer_stream}
        else
          {:ok, []} ->
            {:error, "Client not returned a stream"}

          {:error, reason} ->
            {:error, reason}
        end

      GenServer.reply(from, stream_result)
    end)

    {:noreply, state}
  end

  @impl true
  def handle_info(msg, state) do
    Logger.notice("Received unexpected message: #{inspect(msg)}")

    {:noreply, state}
  end

  def unary_req(%{entity_type: entity_type} = ctx, message) do
    GenServer.call(get_name(entity_type), {:handle_unary, %{context: ctx, payload: message}})
  end

  def streamed_req(%{entity_type: entity_type} = ctx, messages) do
    GenServer.call(get_name(entity_type), {:handle_streamed, %{context: ctx, payload: messages}})
  end

  defp process_command(
         _command_processor,
         _context,
         %ActionResponse{response: {:reply, %Cloudstate.Reply{} = _reply}} = message
       ) do
    {:ok, message}
  end

  defp process_command(
         _command_processor,
         _context,
         %ActionResponse{response: {:failure, %Cloudstate.Failure{} = _failure}} = message
       ) do
    {:ok, message}
  end

  defp process_command(
         _command_processor,
         _context,
         %ActionResponse{response: {:forward, %Cloudstate.Forward{} = _forward}} = message
       ) do
    {:ok, message}
  end

  defp process_command(nil, _context, message) do
    {:ok, message}
  end

  defp handle_effects([]), do: {:ok, []}

  defp handle_effects(effects) when is_list(effects) and length(effects) > 0 do
  end

  defp handle_effects(_), do: {:ok, []}

  defp get_name(entity_type) do
    mod =
      entity_type
      |> String.split(".")
      |> Enum.at(-1)

    Module.concat(__MODULE__, mod)
  end

  defp run_stream(client_stream, messages) do
    Logger.debug("Running client stream #{inspect(messages)}")

    Stream.filter(messages, &is_command_valid?(&1))
    |> Stream.map(&send_stream_msg(client_stream, &1))
  end

  defp is_command_valid?(:halt), do: true
  defp is_command_valid?(%Cloudstate.Action.ActionCommand{payload: nil}), do: false
  defp is_command_valid?(%Cloudstate.Action.ActionCommand{payload: _payload}), do: true

  defp send_stream_msg(client_stream, :halt) do
    Logger.debug("send_stream_msg :halt")
    GRPC.Stub.end_stream(client_stream)
  end

  defp send_stream_msg(client_stream, msg) do
    Logger.debug("send_stream_msg #{inspect(msg)}")
    GRPC.Stub.send_request(client_stream, msg, [])
  end
end
