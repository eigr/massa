defmodule StoreTest do
  use ExUnit.Case
  doctest Store

  test "greets the world" do
    assert Store.hello() == :world
  end
end
