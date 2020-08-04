defmodule EventingSqsTest do
  use ExUnit.Case
  doctest EventingSqs

  test "greets the world" do
    assert EventingSqs.hello() == :world
  end
end
