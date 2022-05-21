defmodule RuntimeWasmTest do
  use ExUnit.Case
  doctest RuntimeWasm

  test "greets the world" do
    assert RuntimeWasm.hello() == :world
  end
end
