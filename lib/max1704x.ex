defmodule Max1704x do
  @moduledoc """
  MAX17040 AND MAX17041 Driver using Wafer.
  """

  @derive [Wafer.I2C, Wafer.Chip]
  defstruct [:conn, :variant]
  alias Wafer.Conn
  import Max1704x.Registers
  @behaviour Wafer.Conn

  @type t :: %__MODULE__{conn: Conn.t(), variant: :max17040 | :max17041}

  @option_schema [
    conn: [
      type: :any,
      required: true,
      doc: "The connection to the underying I2C bus"
    ],
    variant: [
      type: {:in, [:max17040, :max17041]},
      required: true,
      doc: "The variant of the IC being communicated with"
    ]
  ]

  @type options :: [unquote(Spark.Options.option_typespec(@option_schema))]

  @doc """
  Acquire a connection to the MAX1704x device using the passed-in I2C
  connection.
  """
  @doc spark_opts: [{4, @option_schema}]
  @spec acquire(options) :: {:ok, t} | {:error, any}
  def acquire(options) do
    with {:ok, opts} <- Spark.Options.validate(options, @option_schema) do
      {:ok, %__MODULE__{conn: opts[:conn], variant: opts[:variant]}}
    end
  end

  @doc """
  The current voltage of the connected cell.
  """
  @spec current_voltage(t) :: {:ok, float} | {:error, any}
  def current_voltage(%__MODULE__{conn: conn, variant: :max17040}) do
    with {:ok, <<value::unsigned-integer-big-size(12), _::bitstring>>} <- read_vcell(conn) do
      {:ok, value * 1.25 / 1000}
    end
  end

  def current_voltage(%__MODULE__{conn: conn, variant: :max17041}) do
    with {:ok, <<value::unsigned-integer-big-size(12), _::bitstring>>} <- read_vcell(conn) do
      {:ok, value * 2.5 / 1000}
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
