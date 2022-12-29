defmodule Ash.Serial.ConfigTest do
  use ExUnit.Case
  alias Ash.Serial.Port

  setup do
    pid = Socat.start()
    on_exit(fn -> Socat.stop(pid) end)
  end

  test "valid config test" do
    test_config("8N1")
    test_config("8N2")
    test_config("8E1")
    test_config("8E2")
    test_config("8O1")
    test_config("8O2")
    test_config("7N1")
    test_config("7N2")
    test_config("7E1")
    test_config("7E2")
    test_config("7O1")
    test_config("7O2")
  end

  defp test_config(config) do
    port0 = Port.open(path: Socat.socat0(), config: config)
    port1 = Port.open(path: Socat.socat1(), config: config)
    Tests.test_ping(port0, port1)
    true = Port.close(port0)
    true = Port.close(port1)
  end
end
