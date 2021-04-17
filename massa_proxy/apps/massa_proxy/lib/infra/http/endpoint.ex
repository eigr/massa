defmodule Http.Endpoint do
  @moduledoc """
  A Plug responsible for logging request info, parsing request body's as JSON,
  matching routes, and dispatching responses.
  """

  use Plug.Router

  plug(Plug.Logger)

  plug(Http.PlugExporter)
  plug(Http.MetricsExporter)

  plug(:match)

  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)

  plug(:dispatch)

  get "/health" do
    send_resp(conn, 200, "up!")
  end

  match(_, to: TranscoderRouter)
end
