defmodule Runtime do
  @moduledoc """
  `Runtime`.
  """
  use Supervisor

  alias Runtime.Protocol.Middleware

  defmodule MiddlewareDefinition do
    defstruct entity_type: nil, module: nil

    @type t(entity_type, module) :: %MiddlewareDefinition{
            entity_type: entity_type,
            module: module
          }

    @type t :: %MiddlewareDefinition{entity_type: String.t(), module: module()}
  end

  defmodule State do
    defstruct middlewares: []

    @type t(middlewares) :: %State{middlewares: middlewares}

    @type t :: %State{middlewares: list(%MiddlewareDefinition{})}
  end

  @spec start_link(State.t()) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(state \\ %{}) do
    Supervisor.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl true
  def init(%State{middlewares: middlewares} = _state) do
    Enum.map(middlewares, fn %MiddlewareDefinition{entity_type: type, module: _module} =
                               _middleware ->
      _process_name = get_name(type)
    end)

    children = [
      Runtime.Entity.EntityRegistry.child_spec(%{})
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  # @impl true
  # def start(_type, _args) do
  #   children =
  #     [
  #       {Task.Supervisor, name: ProxyRuntime.TaskSupervisor},
  #       {Runtime.Entity.EntityRegistry.Supervisor, [%{}]}
  #     ]
  #     |> Stream.reject(&is_nil/1)
  #     |> Enum.to_list()

  #   opts = [strategy: :one_for_one, name: ProxyRuntime.Supervisor]
  #   Supervisor.start_link(children, opts)
  # end

  defp get_name(entity_type) do
    mod =
      entity_type
      |> String.split(".")
      |> Enum.at(-1)

    Module.concat(Middleware, mod)
  end
end
