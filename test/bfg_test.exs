defmodule BfgTest do
  use ExUnit.Case
  doctest Bfg

  test "greets the world" do
    assert Bfg.hello() == :world
  end
end
