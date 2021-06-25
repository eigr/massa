defmodule Infra.Http.TranscodingProxyRouter do
  @moduledoc """
  Simple proxy for handle http requests.
  All requests sended to Http Router
  """
  require Logger
  alias MassaProxy.Server.HttpRouter

  def init(opts), do: opts

  def call(conn, opts) do
    Logger.debug("HTTP Request: #{inspect(conn)}:#{inspect(opts)}")
    HttpRouter.routing(%{request: conn, opts: opts})
  end
end
