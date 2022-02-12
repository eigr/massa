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
        {:handle_unary, message},
        _from,
        # %{command_processor: command_processor} = state
        state
      ) do
    result =
      with {:ok, channel} <- get_connection(),
           {:ok, %ActionResponse{side_effects: effects} = commands} <-
             ActionClient.handle_unary(channel, message),
           {:ok, result} <- process_command(nil, commands) do
        handle_effects(effects)
        {:ok, result}
      else
        {:error, reason} -> {:error, "Failure to make unary request #{inspect(reason)}"}
      end

    Logger.debug("User function response #{inspect(result)}")

    {:reply, result, state}
  end

  @impl true
  def handle_call({:handle_streamed, _messages}, from, state) do
    spawn(fn ->
      stream_result = nil
      GenServer.reply(from, stream_result)
    end)

    {:noreply, state}
  end

  @impl true
  def handle_info(msg, state) do
    Logger.notice("Received unexpected message: #{inspect(msg)}")

    {:noreply, state}
  end

  def unary_req(entity_type, message) do
    GenServer.call(get_name(entity_type), {:handle_unary, message})
  end

  def streamed_req(entity_type, messages) do
    GenServer.call(get_name(entity_type), {:handle_streamed, messages})
  end

  defp process_command(
         _command_processor,
         %ActionResponse{response: {:reply, %Cloudstate.Reply{} = _reply}} = message
       ) do
    {:ok, message}
  end

  defp process_command(
         _command_processor,
         %ActionResponse{response: {:failure, %Cloudstate.Failure{} = _failure}} = message
       ) do
    {:ok, message}
  end

  defp process_command(
         _command_processor,
         %ActionResponse{response: {:forward, %Cloudstate.Forward{} = _forward}} = message
       ) do
    {:ok, message}
  end

  defp process_command(nil, message) do
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
end
