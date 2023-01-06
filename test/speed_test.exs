defmodule Dpi.Serial.SpeedTest do
  use ExUnit.Case
  alias Dpi.Serial.Port
  alias Dpi.Serial.Params

  setup do
    pid = Socat.start()
    on_exit(fn -> Socat.stop(pid) end)
  end

  test "valid speed test" do
    for speed <- Params.speed() do
      test_speed(speed)
    end
  end

  defp test_speed(speed) do
    port0 = Port.open(path: Socat.socat0(), speed: speed)
    port1 = Port.open(path: Socat.socat1(), speed: speed)
    Tests.test_ping(port0, port1)
    true = Port.close(port0)
    true = Port.close(port1)
  end
end
