defmodule Runtime.GRPC.Protocol.Action.Processor do
  @moduledoc """
  This module defines the command processor for actions.
  """
  require Logger

  alias Cloudstate.Action.ActionResponse

  @behaviour Runtime.Protocol.CommandProcessor

  def apply(
        _context,
        %ActionResponse{response: {:reply, %Cloudstate.Reply{} = _reply}} = message
      ) do
    {:ok, message}
  end

  def apply(
        _context,
        %ActionResponse{response: {:failure, %Cloudstate.Failure{} = _failure}} = message
      ) do
    {:ok, message}
  end

  def apply(
        _context,
        %ActionResponse{response: {:forward, %Cloudstate.Forward{} = _forward}} = message
      ) do
    {:ok, message}
  end

  def apply(
        _context,
        %ActionResponse{response: nil} = _message
      ) do
    {:ok, %ActionResponse{}}
  end

  def apply(nil, _context, message) do
    {:ok, message}
  end
end
