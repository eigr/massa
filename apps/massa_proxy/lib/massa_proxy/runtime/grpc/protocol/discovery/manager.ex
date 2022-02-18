defmodule MassaProxy.Runtime.Grpc.Protocol.Discovery.Manager do
  @moduledoc false
  require Logger
  use Injectx
  use ExRay, pre: :before_fun, post: :after_fun

  alias ExRay.Span
  alias MassaProxy.CloudstateEntity
  alias MassaProxy.Server.GrpcServer
  alias Google.Protobuf.FileDescriptorSet
  alias Runtime.{Entity.EntityRegistry, Util}

  inject(MassaProxy.Infra.Config)

  @protocol_minor_version 1
  @proxy_name "massa-proxy"
  @supported_entity_types [
    "cloudstate.action.ActionProtocol",
    "cloudstate.eventsourced.EventSourced"
  ]

  # Generates a request id
  @req_id "#{inspect(:os.system_time(:milli_seconds) |> Integer.to_string())}"

  @trace kind: :critical
  def report_error(error) do
    with {:ok, channel} <- get_connection() do
      {_, response} =
        channel
        |> Cloudstate.EntityDiscovery.Stub.report_error(error)

      GRPC.Stub.disconnect(channel)
      Logger.info("User function report error reply #{inspect(response)}")
      response
    end
  end

  @trace kind: :normal
  def discover(message) do
    Logger.info("#{startup_message(is_uds_enable?())}")

    case :ets.lookup(:servers, :grpc) do
      [] ->
        with {:ok, channel} <- get_connection(),
             {:ok, file_descriptors, user_entities} <-
               channel
               |> Cloudstate.EntityDiscovery.Stub.discover(message)
               |> handle_response() do
          GrpcServer.start(file_descriptors, user_entities)
          GRPC.Stub.disconnect(channel)
        end

      _ ->
        Logger.debug("The user's function has already been registered. Nothing to do!")
    end
  end

  defp handle_response(response) do
    extract_message(response)
    |> validate()
    |> register_entities()
  end

  defp register_entities({:ok, message}) do
    entities = message.entities
    descriptor = FileDescriptorSet.decode(message.proto)
    file_descriptors = descriptor.file

    user_entities =
      entities
      |> Flow.from_enumerable()
      |> Flow.map(&parse_entity(&1, file_descriptors))
      |> Flow.map(&register_entity/1)
      |> Enum.to_list()

    Logger.debug("Found #{Enum.count(user_entities)} Entities to processing.")
    {:ok, file_descriptors, user_entities}
  end

  defp register_entity(entity) do
    Logger.debug("Registering entity #{inspect(entity)}")

    case entity.entity_type do
      "cloudstate.eventsourced.EventSourced" ->
        EntityRegistry.register("EventSourced", [entity])

      "cloudstate.action.ActionProtocol" ->
        EntityRegistry.register("Action", [entity])

      _ ->
        Logger.warn("Unknown Entity #{entity.entity_type}")
    end

    entity
  end

  defp parse_entity(entity, file_descriptors) do
    messages =
      file_descriptors
      |> Flow.from_enumerable()
      |> Flow.map(&extract_messages/1)
      |> Enum.reduce([], fn elem, acc ->
        acc ++ [elem]
      end)
      |> List.flatten()

    services =
      file_descriptors
      |> Flow.from_enumerable()
      |> Flow.map(&extract_services(&1, entity.service_name))
      |> Enum.reduce([], fn elem, acc ->
        acc ++ [elem]
      end)
      |> List.flatten()

    %CloudstateEntity{
      node: Node.self(),
      entity_type: entity.entity_type,
      service_name: entity.service_name,
      persistence_id: entity.persistence_id,
      messages: Enum.filter(messages, fn x -> x != [] end),
      services: Enum.filter(services, fn x -> x != [] end)
    }
  end

  defp extract_messages(file) do
    file.message_type
    |> Flow.from_enumerable()
    |> Flow.map(&to_message_item/1)
    |> Enum.reduce([], fn elem, acc ->
      acc ++ [elem]
    end)
    |> List.flatten()
  end

  defp extract_services(file, service_name) do
    name =
      service_name
      |> String.split(".")
      |> List.last()

    file.service
    |> Flow.from_enumerable()
    |> Flow.filter(fn service ->
      String.trim(service.name) != "" && service.name == name
    end)
    |> Flow.map(&to_service_item/1)
    |> Enum.reduce([], fn elem, acc ->
      acc ++ [elem]
    end)
    |> List.flatten()
  end

  defp to_message_item(message) do
    attributes =
      message.field
      |> Flow.from_enumerable()
      |> Flow.map(&extract_field_attributes/1)
      |> Enum.to_list()

    %{name: message.name, attributes: attributes}
  end

  defp to_service_item(service) do
    methods =
      service.method
      |> Flow.from_enumerable()
      |> Flow.map(&extract_service_method/1)
      |> Enum.to_list()

    %{name: service.name, methods: methods}
  end

  defp extract_field_attributes(field) do
    has_key =
      if field.options != nil do
        opts = Util.contains_key?(field)
        Logger.debug("Has key?: #{inspect(opts)}")
      end

    type_options =
      if field.options != nil && field.options.ctype != nil do
        field.options.ctype
      end

    %{
      name: field.name,
      number: field.number,
      type: field.type,
      label: field.label,
      entity_id: has_key,
      options: %{type: type_options}
    }
  end

  defp extract_service_method(method) do
    http_options =
      if method.options != nil do
        http_rules = Util.get_http_rule(method)
        Logger.debug("MehodOptions: #{inspect(http_rules)}")

        %{type: "http", data: http_rules}
      end

    eventing_options =
      if method.options != nil do
        evt_rules = Util.get_eventing_rule(method)
        Logger.debug("MehodOptions: #{inspect(evt_rules)}")

        %{type: "eventing", data: evt_rules}
      end

    svc = %{
      name: method.name,
      unary: is_unary(method),
      streamed: is_streamed(method),
      input_type: method.input_type,
      output_type: method.output_type,
      stream_in: method.client_streaming,
      stream_out: method.server_streaming,
      options: [http_options, eventing_options]
    }

    Logger.debug("Service mapped #{inspect(svc)}")
    svc
  end

  defp is_unary(method) do
    if method.client_streaming == false && method.server_streaming == false do
      true
    else
      false
    end
  end

  defp is_streamed(method) do
    if method.client_streaming == true && method.server_streaming == true do
      true
    else
      false
    end
  end

  defp validate(message) do
    entities = message.entities

    if Enum.empty?(entities) do
      Logger.error("No entities were reported by the discover call!")
      raise "No entities were reported by the discover call!"
    end

    entities
    |> Enum.each(fn entity ->
      if !Enum.member?(@supported_entity_types, entity.entity_type) do
        Logger.error("This proxy not support entities of type #{entity.entity_type}")
        raise "This proxy not support entities of type #{entity.entity_type}"
      end
    end)

    if !is_binary(message.proto) do
      Logger.error("No descriptors found in EntitySpec")
      raise "No descriptors found in EntitySpec"
    end

    if String.trim(message.service_info.service_name) == "" do
      Logger.warn("Service Info does not provide a service name")
    end

    {:ok, message}
  end

  defp extract_message(response) do
    case response do
      {:ok, message} ->
        Logger.info("Received EntitySpec from user function with info: #{inspect(message)}")
        message

      _ ->
        Logger.error("Error -> #{inspect(response)}")
    end
  end

  defp before_fun(ctx) do
    ctx.target
    |> Span.open(@req_id)
    |> :otter.tag(:kind, ctx.meta[:kind])
    |> :otter.tag(:component, __MODULE__)
    |> :otter.log(">>> #{ctx.target} with #{ctx.args |> inspect}")
  end

  defp after_fun(ctx, span, res) do
    span
    |> :otter.log("<<< #{ctx.target} returned #{res |> inspect}")
    |> Span.close(@req_id)
  end

  defp get_address("false"), do: get_address(false)
  defp get_address(false), do: "#{get_function_host()}:#{get_function_port()}"
  defp get_address("true"), do: get_address(true)
  defp get_address(true), do: "#{get_uds_address()}"

  defp startup_message(uds_enable) do
    case uds_enable do
      true ->
        "Starting #{__MODULE__} on target function address unix://#{get_address(uds_enable)}"

      _ ->
        "Starting #{__MODULE__} on target function address tcp://#{get_address(uds_enable)}"
    end
  end

  defp get_connection(),
    do: GRPC.Stub.connect(get_address(is_uds_enable?()), interceptors: [GRPC.Logger.Client])

  defp is_uds_enable?(),
    do: Config.get(:user_function_uds_enable)

  defp get_function_port(), do: Config.get(:user_function_port)

  defp get_function_host(), do: Config.get(:user_function_host)

  defp get_uds_address(), do: Config.get(:user_function_sock_addr)
end
