defmodule Max1704x.Registers do
  use Wafer.Registers

  @moduledoc """
  Functions for interacting with the IC registers.

  ## VCELL

  Battery voltage is measured at the CELL pin input with respect to GND over a 0
  to 5.00V range for the MAX17040 and 0 to 10.00V for the MAX17041 with
  resolutions of 1.25mV and 2.50mV, respectively. The A/D calculates the average
  cell voltage for a period of 125ms after IC POR and then for a period of 500ms
  for every cycle afterwards. The result is placed in the VCELL register at the
  end of each conversion period.

  12-bits encoded in a 16 bit read-only register with four trailing 0 bytes.

  ## SOC

  The SOC register is a read-only register that displays the state of charge of
  the cell as calculated by the ModelGauge algorithm. The result is displayed as
  a percentage of the cell’s full capacity. This register auto- matically adapts
  to variation in battery size since the MAX17040/MAX17041 naturally recognize
  relative SOC. Units of % can be directly determined by observing only the high
  byte of the SOC register. The low byte provides additional resolution in units
  1/256%. The reported SOC also includes residual capacity, which might not be
  avail- able to the actual application because of early termination voltage
  requirements. When SOC() = 0, typical applica- tions have no remaining
  capacity. The first update occurs within 250ms after POR of the IC. Subsequent
  updates occur at variable intervals depend- ing on application conditions.
  ModelGauge calculations outside the register are clamped at minimum and maxi-
  mum register limits

  16 bit read-only register.

  ## MODE

  The MODE register allows the host processor to send special commands to the
  IC. Valid MODE register write values are listed as follows. All other MODE
  register values are reserved.

  - `0x4000` - Quick-Start

  16 bit write-only register.

  ## VERSION

  The VERSION register is a read-only register that contains a value indicating
  the production version of the MAX17040/MAX17041

  16 bit read-only register.

  ## RCOMP

  RCOMP is a 16-bit value used to compensate the ModelGauge algorithm. RCOMP can
  be adjusted to optimize performance for different lithium chemistries or
  different operating temperatures. Contact Maxim for instructions for
  optimization. The factory-default value for RCOMP is 0x9700.

  16 bit read-write register.

  ## COMMAND

  The COMMAND register allows the host processor to send special commands to the
  IC. Valid COMMAND register write values are listed as follows. All other
  COMMAND register values are reserved.

  - `0x0054` - Power-On Reset.

  16 bit write-only register.
  """

  defregister(:vcell, 0x2, :ro, 2)
  defregister(:soc, 0x4, :ro, 2)
  defregister(:mode, 0x6, :wo, 2)
  defregister(:version, 0x8, :ro, 2)
  defregister(:rcomp, 0xC, :rw, 2)
  defregister(:command, 0xFE, :wo, 2)
end
