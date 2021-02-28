defmodule EventingTest do
  use ExUnit.Case
  doctest Eventing

  test "greets the world" do
    assert Eventing.hello() == :world
  end
end
