defmodule MassaProxy.Server do
  require Logger

  alias Protobuf.Protoc.Context
  alias Protobuf.Protoc.Generator.Extension, as: Generator

  def start(descriptors, entities) do
    descriptors
    |> compile
  end

  defp compile(descriptors) do
  end
end
