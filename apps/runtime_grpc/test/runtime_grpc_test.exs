defmodule RuntimeGrpcTest do
  use ExUnit.Case
  doctest RuntimeGrpc

  test "greets the world" do
    assert RuntimeGrpc.hello() == :world
  end
end
