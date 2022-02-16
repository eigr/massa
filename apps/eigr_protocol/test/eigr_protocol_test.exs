defmodule EigrProtocolTest do
  use ExUnit.Case
  doctest EigrProtocol

  test "greets the world" do
    assert EigrProtocol.hello() == :world
  end
end
