defmodule Ash.Serial.Port do
  @opts [:path, :config, :speed]

  def open(opts) do
    args =
      for {key, value} <- Keyword.take(opts, @opts) do
        "--#{key}=#{value}"
      end

    opts = [:binary, :exit_status, :stream, args: args]
    priv = :code.priv_dir(:ash_serial)
    target = File.read!("#{priv}/target") |> String.trim()
    Port.open({:spawn_executable, '#{priv}/#{target}/ash_serial'}, opts)
  end

  def write!(port, iodata) do
    true = Port.command(port, iodata)
  end

  def close(port) do
    Port.close(port)
  end
end
