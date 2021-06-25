defmodule CloudstateProtocolTest do
  use ExUnit.Case
  doctest CloudstateProtocol

  test "greets the world" do
    assert CloudstateProtocol.hello() == :world
  end
end
