defmodule MassaProxy.Reflection.Server do
  @moduledoc """

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

    {:reply, response, state}
  end

  @impl true
  def handle_call({:file_by_filename, filename}, _from, state) do
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
          {:file_descriptor_response, FileDescriptorResponse.new(file_descriptor_proto: files)}
      )

    {:reply, response, state}
  end

  @impl true
  def handle_call({:file_containing_symbol, symbol}, _from, state) do
    with {:fail, :empty} <- contains_service(state, symbol) do
      response =
        ServerReflectionResponse.new(
          message_response:
            {:error_response, ErrorResponse.new(error_code: 5, error_message: "Symbol Not Found")}
        )

      {:reply, response, state}
    else
      {:ok, description} ->
        response =
          ServerReflectionResponse.new(
            message_response:
              {:file_descriptor_response,
               FileDescriptorResponse.new(file_descriptor_proto: description)}
          )

        {:reply, response, state}
    end
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
end
