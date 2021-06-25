defmodule MassaProxyTest do
  use ExUnit.Case
  doctest MassaProxy

  test "greets the world" do
    assert MassaProxy.hello() == :world
  end
end
