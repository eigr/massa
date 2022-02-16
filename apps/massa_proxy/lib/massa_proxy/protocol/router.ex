defmodule MassaProxy.Protocol.Router do
  @doc """
  Dispatch the given `mod`, `fun`, `args` request
  to the appropriate node based on the `bucket`.
  """
  require Logger

  alias MassaProxy.Entity.EntityRegistry
  alias MassaProxy.TaskSupervisor

  @timeout 10000

  def route(
        entity_type,
        service_name,
        command_name,
        input_type,
        async \\ false,
        mod,
        fun,
        payload
      ) do
    with node_entities <- EntityRegistry.lookup(entity_type, service_name, command_name) do
      Logger.debug("Routing request to #{inspect(node_entities)}")

      targets =
        Enum.map(node_entities, fn %{node: member, entity: entity} = _node_entity ->
          if member == node() do
            {:local, node(), entity}
          else
            {:remote, member, entity}
          end
        end)
        |> List.flatten()

      result =
        case Enum.find(targets, fn target -> match?({:local, _, _}, target) end) do
          {:local, _member, entity} ->
            Logger.debug("Local: #{entity}")

            payload = %{
              payload
              | entity_type: entity_type,
                service_name: service_name,
                request_type: "unary",
                original_method: command_name,
                input_type: input_type,
                output_type: "",
                persistence_id: nil,
                message: payload,
                stream: nil
            }

            apply(mod, fun, [payload])

          nil ->
            Logger.debug("Remote: #{targets}")
            {:remote, member, entity} = List.first(targets)

            Logger.debug("Remote: #{entity}")

            payload = %{
              payload
              | entity_type: entity_type,
                service_name: service_name,
                request_type: "unary",
                original_method: command_name,
                input_type: input_type,
                output_type: "",
                persistence_id: nil,
                message: payload,
                stream: nil
            }

            call(member, async, mod, fun, [payload])
        end

      result
    else
      [] -> {:unrouted, :not_found}
    end
  end

  defp call(node, true, mod, fun, args) do
    Logger.debug("Invoking remote call on node #{inspect(node)}")

    pid =
      Node.spawn(node, fn ->
        Kernel.apply(__MODULE__, :route, [mod, fun, args])
      end)

    {:routed, :fire_and_forget, pid}
  end

  defp call(node, false, mod, fun, args) do
    remote_result =
      {TaskSupervisor, node}
      |> Task.Supervisor.async(__MODULE__, :route, [mod, fun, args])
      |> Task.await(@timeout)

    {:routed, remote_result}
  end
end
