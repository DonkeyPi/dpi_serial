defmodule AshSerialTest do
  use ExUnit.Case
  doctest AshSerial

  test "greets the world" do
    assert AshSerial.hello() == :world
  end
end
