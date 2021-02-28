defmodule StorePostgresTest do
  use ExUnit.Case
  doctest StorePostgres

  test "greets the world" do
    assert StorePostgres.hello() == :world
  end
end
