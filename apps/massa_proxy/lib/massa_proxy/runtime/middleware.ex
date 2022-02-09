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

  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call(
        {:handle_unary, message},
        _from,
        %{command_processor: command_processor} = state
      ) do
    result =
      with {:ok, channel} <- get_connection(),
           {:ok, result} <- ActionClient.handle_unary(channel, message),
           {:ok, %ActionResponse{response: _response, side_effects: effects} = result} <-
             process_command(command_processor, result) do
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

  def unary_req(server, message) do
    GenServer.call(server, {:handle_unary, message})
  end

  def stream_req(server, messages) do
    GenServer.call(server, {:handle_streamed, messages})
  end

  defp handle_effects(_effects) do
  end

  defp process_command(_command_processor, action_response) do
    {:ok, action_response}
  end
end
