defmodule EventingCloudPubsubTest do
  use ExUnit.Case
  doctest EventingCloudPubsub

  test "greets the world" do
    assert EventingCloudPubsub.hello() == :world
  end
end
