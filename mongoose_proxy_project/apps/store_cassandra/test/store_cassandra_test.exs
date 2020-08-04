defmodule StoreCassandraTest do
  use ExUnit.Case
  doctest StoreCassandra

  test "greets the world" do
    assert StoreCassandra.hello() == :world
  end
end
