defmodule TranscoderRouter do
  require Logger

  def init(opts), do: opts

  def call(conn, opts) do
    Logger.debug("-------------> #{inspect(conn)}:#{inspect(opts)}")
  end
end
