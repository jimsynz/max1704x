defmodule Max1704x do
  @moduledoc """
  MAX17040 AND MAX17041 Driver using Wafer.
  """

  @derive Wafer.I2C
  defstruct [:conn, :variant]
  alias Wafer.Conn
  import Max1704x.Registers

  @type t :: %__MODULE__{conn: Conn.t()}
  @type variant :: 0 | 1

  @doc """
  Acquire a connection to the MAX1704x device using the passed-in I2C
  connection.

  The `variant` option selects which IC to use (affects voltage scaling). Use
  `0` for MAX17040 and `1` for MAX17041.
  """
  @spec acquire(Conn.t(), variant) :: {:ok, t} | {:error, any}
  def acquire(conn, variant) when variant in [0, 1],
    do: {:ok, %__MODULE__{conn: conn, variant: variant}}

  def acquire(_conn, variant), do: {:error, "Invalid variant #{inspect(variant)}"}

  @doc """
  The current voltage of the connected cell.
  """
  @spec current_voltage(t) :: {:ok, float} | {:error, any}
  def current_voltage(conn) do
    with {:ok, <<value::unsigned-integer-big-size(12), _::bitstring>>} <- read_vcell(conn) do
      {:ok, value * 1.25 / 1000}
    end
  end

  @doc """
  The current state-of-charge of the connected cell (in %).
  """
  @spec current_charge(t) :: {:ok, float} | {:error, any}
  def current_charge(conn) do
    with {:ok, <<msb, lsb>>} <- read_soc(conn) do
      value =
        lsb
        |> Kernel./(256)
        |> Kernel.+(msb)

      {:ok, value}
    end
  end

  @doc """
  Asks the IC to perform a quick-start.

  See the Quick-Start section of [the data sheet](https://www.analog.com/media/en/technical-documentation/data-sheets/MAX17040-MAX17041.pdf).
  """
  @spec quickstart!(t) :: {:ok, t} | {:error, any}
  def quickstart!(conn), do: write_mode(conn, <<0x4000::unsigned-integer-big-size(16)>>)

  @doc """
  Asks the IC to perform a power-on-reset.

  See the Power-On Reset section of [the data sheet](https://www.analog.com/media/en/technical-documentation/data-sheets/MAX17040-MAX17041.pdf).
  """
  @spec power_on_reset!(t) :: {:ok, t} | {:error, any}
  def power_on_reset!(conn), do: write_command(conn, <<0x0054::unsigned-integer-big-size(16)>>)

  @doc """
  Returns the IC version.
  """
  @spec version(t) :: {:ok, 0..0xF} | {:error, any}
  def version(conn) do
    with {:ok, <<value::unsigned-integer-big-size(16)>>} <- read_version(conn) do
      {:ok, value}
    end
  end

  @doc """
  Returns the current version of the compensation value.
  """
  @spec compensation(t) :: {:ok, 0..0xFFFF} | {:error, any}
  def compensation(conn) do
    with {:ok, <<value::unsigned-integer-big-size(16)>>} <- read_rcomp(conn) do
      {:ok, value}
    end
  end

  @doc """
  Set the value used to compensate the ModelGauge algorithm.
  """
  @spec compensation(t, 0..0xFFFF) :: {:ok, non_neg_integer()} | {:error, any}
  def compensation(conn, value) when is_integer(value) and value > 0 and value < 0xFFFF,
    do: write_rcomp(conn, <<value::unsigned-integer-size(16)>>)

  def compensation(_conn, other), do: {:error, "Invalid compensation value: #{inspect(other)}"}
end
