defmodule TWSAPIExTest do
  use ExUnit.Case
  doctest TWSAPIEx

  test "greets the world" do
    assert TWSAPIEx.hello() == :world
  end
end
