defmodule MongooseProxy.Application do
  use Application

  @impl true
  def start(_type, _args) do
    MongooseProxy.Supervisor.start_link([])
  end

end
