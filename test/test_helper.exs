ExUnit.start()

defmodule Tests do
  alias Dpi.Serial.Port

  @toms 200

  def test_ping(port0, port1) do
    Port.write!(port0, "ping")
    wait_for!(port1, "ping")
    Port.write!(port1, "ping")
    wait_for!(port0, "ping")
  end

  defp wait_for!(port, target) do
    :ok = wait_for(port, target, "")
  end

  defp wait_for(_port, target, target), do: :ok

  defp wait_for(port, target, buffer) do
    receive do
      {^port, {:data, data}} ->
        wait_for(port, target, buffer <> data)

      {^port, {:exit_status, status}} ->
        raise "port exited #{status}"
    after
      @toms -> raise "port read timeout"
    end
  end
end

defmodule Socat do
  @socat0 "/tmp/dpi.socat0"
  @socat1 "/tmp/dpi.socat1"
  @args ["-d", "-d", "pty,link=#{@socat0}", "pty,link=#{@socat1}"]
  @toms 200

  def socat0(), do: @socat0
  def socat1(), do: @socat1

  def start() do
    pid = spawn_link(&run/0)
    wait_path!(@socat0)
    wait_path!(@socat1)
    pid
  end

  def stop(pid) do
    Process.exit(pid, :exit)
    wait_pid!(pid)
  end

  defp run() do
    Process.flag(:trap_exit, true)
    exec = System.find_executable("socat")

    port =
      Port.open(
        {:spawn_executable, exec},
        [:binary, :exit_status, :stderr_to_stdout, args: @args]
      )

    {:os_pid, pid} = Port.info(port, :os_pid)

    handle = fn handle ->
      receive do
        {^port, {:data, _data}} ->
          # IO.puts(data)
          handle.(handle)

        _ ->
          System.cmd("kill", ["-9", "#{pid}"])
          File.rm(@socat0)
          File.rm(@socat1)
      end
    end

    handle.(handle)
  end

  defp wait_path!(path) do
    :ok = wait_path(path, @toms)
  end

  defp wait_path(_path, 0), do: :to

  defp wait_path(path, toms) do
    case File.exists?(path) do
      true ->
        :ok

      _ ->
        :timer.sleep(1)
        wait_path(path, toms - 1)
    end
  end

  defp wait_pid!(pid) do
    :ok = wait_pid(pid, @toms)
  end

  defp wait_pid(_pid, 0), do: :to

  defp wait_pid(pid, toms) do
    case Process.alive?(pid) do
      false ->
        :ok

      _ ->
        :timer.sleep(1)
        wait_pid(pid, toms - 1)
    end
  end
end
