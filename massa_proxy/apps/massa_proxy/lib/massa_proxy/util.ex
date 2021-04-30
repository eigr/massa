defmodule MassaProxy.Util do
  @moduledoc false
  require Logger

  def contains_key?(field_descriptor) do
    Logger.debug("FieldOptions: #{inspect(field_descriptor)}")

    entity_key_ext =
      Google.Protobuf.FieldOptions.get_extension(
        field_descriptor.options,
        Cloudstate.PbExtension,
        :entity_key
      )

    Logger.debug("Entity key extension: #{inspect(entity_key_ext)}")
  end

  def get_http_rule(method_descriptor) do
    Logger.debug("MehodOptions HTTP Rules: #{inspect(method_descriptor)}")

    Google.Protobuf.MethodOptions.get_extension(
      method_descriptor.options,
      Google.Api.PbExtension,
      :http
    )
  end

  def get_eventing_rule(method_descriptor) do
    Logger.debug("MehodOptions Eventing Rules: #{inspect(method_descriptor)}")

    evt_ext =
      Google.Protobuf.MethodOptions.get_extension(
        method_descriptor.options,
        Cloudstate.PbExtension,
        :eventing
      )

    Logger.debug("Eventing extension: #{inspect(evt_ext)}")
  end

  def get_type_url(type) do
    parts =
      type
      |> to_string
      |> String.replace("Elixir.", "")
      |> String.split(".")

    package_name =
      with {_, list} <- parts |> List.pop_at(-1),
           do: list |> Enum.map(&String.downcase(&1)) |> Enum.join(".")

    type_name = parts |> List.last()

    "type.googleapis.com/#{package_name}.#{type_name}"
  end

  def compile(file) do
    # if Code.ensure_compiled(file) do
    Code.eval_string(file)
    # end
  end

  def normalize_service_name(name) do
    name
    |> String.split(".")
    |> Enum.map(&Macro.camelize(&1))
    |> Enum.join(".")
  end

  def normalize_mehod_name(name), do: Macro.underscore(name)

  def get_module(filename, bindings \\ []), do: EEx.eval_file(filename, bindings)

  def get_connection(),
    do: GRPC.Stub.connect(get_address(is_uds_enable?()), interceptors: [GRPC.Logger.Client])

  def get_uds_address(),
    do: Application.get_env(:massa_proxy, :user_function_sock_addr, "/var/run/cloudstate.sock")

  def is_uds_enable?(),
    do: Application.get_env(:massa_proxy, :user_function_uds_enable, false)

  defp get_function_host(),
    do: Application.get_env(:massa_proxy, :user_function_host, "127.0.0.1")

  def get_function_port(), do: Application.get_env(:massa_proxy, :user_function_port, 8080)

  def get_address(false), do: "#{get_function_host()}:#{get_function_port()}"

  def get_address(true), do: "#{get_uds_address()}"
end
