defmodule HackerNewsAggregatorTest do
  use ExUnit.Case
  doctest HackerNewsAggregator

  test "greets the world" do
    assert HackerNewsAggregator.hello() == :world
  end
end
