defmodule StoreInmemoryTest do
  use ExUnit.Case
  doctest StoreInmemory

  test "greets the world" do
    assert StoreInmemory.hello() == :world
  end
end
