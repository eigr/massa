defmodule EventingRabbitmqTest do
  use ExUnit.Case
  doctest EventingRabbitmq

  test "greets the world" do
    assert EventingRabbitmq.hello() == :world
  end
end
