defmodule MongooseProxyTest do
  use ExUnit.Case
  doctest MongooseProxy

  test "greets the world" do
    assert MongooseProxy.hello() == :world
  end
end
