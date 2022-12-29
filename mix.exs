defmodule Ash.Serial.MixProject do
  use Mix.Project

  def project do
    [
      app: :ash_serial,
      version: "0.1.0",
      elixir: "~> 1.13",
      make_clean: ["clean"],
      # make_args: ["-dn"],
      compilers: [:elixir_make | Mix.compilers()],
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:elixir_make, "~> 0.6", runtime: false}
    ]
  end
end
