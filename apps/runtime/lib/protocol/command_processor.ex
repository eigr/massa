defmodule Runtime.Protocol.CommandProcessor do
  @moduledoc """
  CommandProcessor executes arbitrary logic on a command.
  """

  @type context :: any()
  @type command :: any()
  @type result :: any()
  @type error :: any()

  @callback apply(context, command) :: {:ok, result} | {:error, error}
end
