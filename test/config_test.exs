defmodule Dpi.Serial.ConfigTest do
  use ExUnit.Case
  alias Dpi.Serial.Port
  alias Dpi.Serial.Params

  setup do
    pid = Socat.start()
    on_exit(fn -> Socat.stop(pid) end)
  end

  test "valid config test" do
    for config <- Params.config() do
      test_config(config)
    end
  end

  defp test_config(config) do
    port0 = Port.open(path: Socat.socat0(), config: config)
    port1 = Port.open(path: Socat.socat1(), config: config)
    Tests.test_ping(port0, port1)
    true = Port.close(port0)
    true = Port.close(port1)
  end
end
