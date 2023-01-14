# Path.wildcard("/dev/ttyS*")
# Path.wildcard("/dev/ttyUSB*")

# {"ttyS0", nil},
# {"ttyUSB0", "FTDI_USB_<->_Serial_Cable_FT0K2HYD"},
# {"ttyUSB1", "FTDI_USB_<->_Serial_Cable_FT0K2HYD"},
# {"ttyUSB2", "FTDI_USB_<->_Serial_Cable_FT0K2HYD"},
# {"ttyUSB3", "FTDI_USB_<->_Serial_Cable_FT0K2HYD"}

# {"ttyS0", nil},
# {"ttyUSB0", "FTDI_USB_<->_Serial_Cable_FT0K2HYD_0"},
# {"ttyUSB1", "FTDI_USB_<->_Serial_Cable_FT0K2HYD_1"},
# {"ttyUSB2", "FTDI_USB_<->_Serial_Cable_FT0K2HYD_2"},
# {"ttyUSB3", "FTDI_USB_<->_Serial_Cable_FT0K2HYD_3"}

defmodule Dpi.Serial.List do
  def find(name) do
    Enum.find_value(list(), name, fn {dev, aka} ->
      if name == dev or name == aka, do: dev
    end)
  end

  def list() do
    case :os.type() do
      {:unix, :darwin} -> list_darwin()
      {:unix, :linux} -> list_linux()
    end
  end

  defp list_ttys() do
    Path.wildcard("/dev/ttyS*") ++ Path.wildcard("/dev/ttyUSB*")
  end

  defp list_darwin() do
    for path <- Enum.sort(Path.wildcard("/dev/tty.*")) do
      name = Path.basename(path)
      {name, nil}
    end
  end

  defp list_linux() do
    list =
      for path <- Enum.sort(list_ttys()) do
        name = Path.basename(path)
        {name, serial_id(name)}
      end

    # ftdi multiports return same serial for all ports
    # sorting above is critical to ensure predictable index
    map =
      Enum.reduce(list, %{}, fn {k, n}, map ->
        v = Map.get(map, {:n, n}, 0)

        map
        |> Map.put({:n, n}, v + 1)
        |> Map.put({:k, k}, tag(n, v))
      end)

    Enum.map(list, fn {k, n} ->
      case Map.get(map, {:n, n}, 0) > 1 do
        true -> {k, Map.get(map, {:k, k})}
        _ -> {k, n}
      end
    end)
  end

  defp tag(nil, _), do: nil
  defp tag(n, v), do: "#{n}_#{v}"

  defp serial_id(name) do
    link = File.read_link!("/sys/class/tty/#{name}")
    link = Path.join("/sys/class/tty", link)
    link = Path.expand(link)
    find_id(link, %{})
  end

  defp find_id("/sys/devices", _), do: nil

  defp find_id(dir, map) do
    with false <- Map.has_key?(map, dir),
         {:ok, manufacturer} <- File.read(Path.join(dir, "manufacturer")),
         {:ok, serial} <- File.read(Path.join(dir, "serial")) do
      manufacturer = manufacturer |> String.trim() |> String.replace(" ", "_")
      serial = serial |> String.trim() |> String.replace(" ", "_")
      "#{manufacturer}_#{serial}"
    else
      true -> nil
      _ -> find_id(Path.dirname(dir), Map.put(map, dir, true))
    end
  end
end
