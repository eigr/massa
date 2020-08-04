defmodule StoreInMemoryTest do
  use ExUnit.Case
  doctest StoreInMemory

  test "greets the world" do
    assert StoreInMemory.hello() == :world
  end
end
