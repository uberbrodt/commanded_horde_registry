defmodule CommandedHordeRegistryTest do
  use ExUnit.Case
  doctest CommandedHordeRegistry

  test "greets the world" do
    assert CommandedHordeRegistry.hello() == :world
  end
end
