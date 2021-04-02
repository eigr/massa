defmodule MassaProxy.Util do
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

  def compile(file), do: Code.eval_string(file)

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
