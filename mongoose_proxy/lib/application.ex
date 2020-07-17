defmodule MongooseProxyApplication do
  use Application

  @impl true
  def start(_type, _args) do
    MongooseProxy.launch()

    children = []
    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end
end
