defmodule RuntimeTest do
  use ExUnit.Case
  doctest Runtime

  test "greets the world" do
    assert Runtime.hello() == :world
  end
end
