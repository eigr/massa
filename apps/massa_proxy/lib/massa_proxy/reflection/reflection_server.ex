defmodule MassaProxy.Reflection.Server do
  @moduledoc """
  This module is responsible for handling all requests
  with a view to contract reflection (reflection.proto)
  """
  use GenServer
  require Logger

  alias Google.Protobuf.{FileDescriptorProto}

  alias Grpc.Reflection.V1alpha.{
    ErrorResponse,
    FileDescriptorResponse,
    ListServiceResponse,
    ServerReflectionResponse,
    ServiceResponse
  }

  alias MassaProxy.Infra.Cache

  def child_spec(state) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [state]}
    }
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call(:list_services, _from, state) do
    response =
      case Cache.get(:reflection_cache, "services") do
        nil ->
          service_response =
            state
            |> Flow.from_enumerable()
            |> Flow.map(&extract_info/1)
            |> Flow.reduce(fn -> [] end, fn s, acc ->
              acc ++ [s]
            end)
            |> Enum.to_list()
            |> List.flatten()

          response =
            ServerReflectionResponse.new(
              message_response:
                {:list_services_response, ListServiceResponse.new(service: service_response)}
            )

          Cache.put(:reflection_cache, "services", response)
          response

        value ->
          value
      end

    {:reply, response, state}
  end

  @impl true
  def handle_call({:file_by_filename, filename}, _from, state) do
    response =
      case Cache.get(:reflection_cache, "file_by_filename_#{filename}") do
        nil ->
          files =
            state
            |> Flow.from_enumerable()
            |> Flow.filter(fn descriptor -> descriptor.name =~ filename end)
            |> Flow.map(fn descriptor -> FileDescriptorProto.encode(descriptor) end)
            |> Flow.reduce(fn -> [] end, fn s, acc ->
              acc ++ [s]
            end)
            |> Enum.to_list()
            |> List.flatten()

          response =
            ServerReflectionResponse.new(
              message_response:
                {:file_descriptor_response,
                 FileDescriptorResponse.new(file_descriptor_proto: files)}
            )

          Cache.put(:reflection_cache, "file_by_filename_#{filename}", response)
          response

        value ->
          value
      end

    {:reply, response, state}
  end

  @impl true
  def handle_call({:file_containing_symbol, symbol}, _from, state) do
    response =
      case Cache.get(:reflection_cache, "file_containing_symbol_#{symbol}") do
        nil ->
          resp =
            with {:fail, :empty} <- contains_service(state, symbol),
                 {:fail, :empty} <- contains_message_type(state, symbol) do
              response =
                ServerReflectionResponse.new(
                  message_response:
                    {:error_response,
                     ErrorResponse.new(error_code: 5, error_message: "Symbol Not Found")}
                )

              response
            else
              {:ok, description} ->
                response =
                  ServerReflectionResponse.new(
                    message_response:
                      {:file_descriptor_response,
                       FileDescriptorResponse.new(file_descriptor_proto: description)}
                  )

                response
            end

          Cache.put(:reflection_cache, "file_containing_symbol_#{symbol}", resp)
          resp

        value ->
          value
      end

    {:reply, response, state}
  end

  # Client API
  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def list_services() do
    GenServer.call(__MODULE__, :list_services)
  end

  def find_by_filename(filename) do
    GenServer.call(__MODULE__, {:file_by_filename, filename})
  end

  def find_by_symbol(symbol) do
    GenServer.call(__MODULE__, {:file_containing_symbol, symbol})
  end

  # Private
  defp contains_service(state, symbol) do
    description =
      state
      |> Flow.from_enumerable()
      |> Flow.map(&get_service(&1, symbol))
      |> Flow.reduce(fn -> [] end, fn s, acc ->
        acc ++ [s]
      end)
      |> Enum.to_list()
      |> List.flatten()

    if Enum.empty?(description) do
      {:fail, :empty}
    else
      {:ok, description}
    end
  end

  defp contains_message_type(state, symbol) do
    description =
      state
      |> Flow.from_enumerable()
      |> Flow.map(&get_messages(&1, symbol))
      |> Flow.reduce(fn -> [] end, fn s, acc ->
        if s != nil || s != [] do
          acc ++ [s]
        else
          acc
        end
      end)
      |> Enum.to_list()
      |> List.flatten()

    if Enum.empty?(description) do
      {:fail, :empty}
    else
      {:ok, Enum.filter(description, &(!is_nil(&1)))}
    end
  end

  defp get_service(descriptor, symbol) do
    services = extract_services(descriptor)

    svcs =
      services
      |> Flow.from_enumerable()
      |> Flow.filter(fn service -> symbol =~ service.name end)
      |> Flow.map(fn _ -> FileDescriptorProto.encode(descriptor) end)
      |> Flow.reduce(fn -> [] end, fn s, acc ->
        acc ++ [s]
      end)
      |> Enum.to_list()

    svcs
  end

  defp get_messages(descriptor, symbol) do
    message_types = extract_messages(descriptor)

    if !Enum.empty?(message_types) do
      types =
        message_types
        |> Flow.from_enumerable()
        |> Flow.filter(fn message -> symbol =~ message.name end)
        |> Flow.map(fn _ -> FileDescriptorProto.encode(descriptor) end)
        |> Flow.reduce(fn -> [] end, fn s, acc ->
          [s] ++ acc
        end)
        |> Enum.to_list()

      types
    end
  end

  defp extract_info(descriptor) do
    package = descriptor.package
    services = extract_services(descriptor)

    svcs =
      services
      |> Flow.from_enumerable()
      |> Flow.map(fn service -> ServiceResponse.new(name: "#{package}.#{service.name}") end)
      |> Flow.reduce(fn -> [] end, fn s, acc ->
        acc ++ [s]
      end)
      |> Enum.to_list()

    svcs
  end

  defp extract_services(file) do
    file.service
    |> Flow.from_enumerable()
    |> Enum.to_list()
  end

  defp extract_messages(file) do
    file.message_type
    |> Flow.from_enumerable()
    |> Enum.to_list()
  end
end
