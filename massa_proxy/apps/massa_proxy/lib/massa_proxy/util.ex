defmodule MassaProxy.Util do
  def compile(file), do: Code.eval_string(file)

  def normalize_service_name(name) do
    name
    |> String.split(".")
    |> Enum.map(&Macro.camelize(&1))
    |> Enum.join(".")
  end

  def normalize_mehod_name(name), do: Macro.underscore(name)

  def get_module(filename, bindings \\ []), do: EEx.eval_file(filename, bindings)
end
