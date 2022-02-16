defmodule MassaProxy.Protocol.Router do
  @doc """
  Dispatch the given `mod`, `fun`, `args` request
  to the appropriate node based on the `bucket`.
  """
  require Logger

  alias MassaProxy.Entity.EntityRegistry
  alias MassaProxy.TaskSupervisor
  alias MassaProxy.Util

  @timeout 10000

  def route(
        entity_type,
        service_name,
        command_name,
        input_type,
        async \\ false,
        mod,
        fun,
        %{message: payload} = message
      ) do
    with node_entities <- EntityRegistry.lookup(entity_type, service_name, command_name) do
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
          {:local, _member, entities} ->
            entity = List.first(entities)

            message = %{
              message
              | entity_type: entity_type,
                service_name: entity.full_service_name,
                request_type: Util.get_type(entity.method),
                original_method: entity.method_name,
                input_type: input_type,
                output_type: to_module(entity.method.output_type),
                persistence_id: entity.persistence_id,
                message: payload,
                stream: nil
            }

            apply(mod, fun, [message])

          nil ->
            {:remote, member, entities} = List.first(targets)
            entity = List.first(entities)

            message = %{
              message
              | entity_type: entity_type,
                service_name: entity.full_service_name,
                request_type: Util.get_type(entity.method),
                original_method: entity.method_name,
                input_type: input_type,
                output_type: to_module(entity.method.output_type),
                persistence_id: entity.persistence_id,
                message: payload,
                stream: nil
            }

            call(member, async, mod, fun, message)
        end

      result
    else
      [] -> {:unrouted, :not_found}
    end
  end

  defp call(node, true, mod, fun, args) do
    Logger.info("Invoking async remote call on node #{inspect(node)}")

    pid =
      Node.spawn(node, fn ->
        Kernel.apply(mod, fun, [args])
      end)

    {:routed, :fire_and_forget, pid}
  end

  defp call(node, false, mod, fun, args) do
    Logger.info("Invoking sync remote call on node #{inspect(node)}")

    remote_result =
      {TaskSupervisor, node}
      |> Task.Supervisor.async(mod, fun, [args])
      |> Task.await(@timeout)

    {:routed, remote_result}
  end

  defp to_module(name) do
    pre_mod =
      name
      |> String.split(".")
      |> Enum.reject(fn elem -> if elem == "", do: true end)
      |> Enum.map(&String.capitalize(&1))

    mod =
      ["Elixir"]
      |> Enum.concat(pre_mod)
      |> Enum.join(".")
      |> String.to_atom()

    mod
  end
end
