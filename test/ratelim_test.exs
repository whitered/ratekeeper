defmodule RatelimTest do
  use ExUnit.Case
  doctest Ratelim

  test "greets the world" do
    assert Ratelim.hello() == :world
  end
end
