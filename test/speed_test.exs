defmodule Ash.Serial.SpeedTest do
  use ExUnit.Case
  alias Ash.Serial.Port

  setup do
    pid = Socat.start()
    on_exit(fn -> Socat.stop(pid) end)
  end

  test "valid speed test" do
    case :os.type() do
      {:unix, :darwin} ->
        test_speed(230_400)
        test_speed(115_200)
        test_speed(76800)
        test_speed(57600)
        test_speed(38400)
        test_speed(28800)
        test_speed(19200)
        test_speed(14400)
        test_speed(9600)
        test_speed(7200)
        test_speed(4800)
        test_speed(2400)
        test_speed(1800)
        test_speed(1200)
        test_speed(600)
        test_speed(300)
        test_speed(200)
        test_speed(150)
        test_speed(134)
        test_speed(110)
        test_speed(75)
        test_speed(50)

      {:unix, :linux} ->
        test_speed(4_000_000)
        test_speed(3_500_000)
        test_speed(3_000_000)
        test_speed(2_500_000)
        test_speed(2_000_000)
        test_speed(1_500_000)
        test_speed(1_152_000)
        test_speed(1_000_000)
        test_speed(921_600)
        test_speed(576_000)
        test_speed(500_000)
        test_speed(460_800)
        test_speed(230_400)
        test_speed(115_200)
        test_speed(57600)
        test_speed(38400)
        test_speed(19200)
        test_speed(9600)
        test_speed(4800)
        test_speed(2400)
        test_speed(1800)
        test_speed(1200)
        test_speed(600)
        test_speed(300)
        test_speed(200)
        test_speed(150)
        test_speed(134)
        test_speed(110)
        test_speed(75)
        test_speed(50)
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
