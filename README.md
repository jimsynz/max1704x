# Max1704x

[![Build Status](https://drone.harton.dev/api/badges/james/max1704x/status.svg)](https://drone.harton.dev/james/max1704x)
[![Hex.pm](https://img.shields.io/hexpm/v/max1704x.svg)](https://hex.pm/packages/max1704x)
[![Hippocratic License HL3-FULL](https://img.shields.io/static/v1?label=Hippocratic%20License&message=HL3-FULL&labelColor=5e2751&color=bc8c3d)](https://firstdonoharm.dev/version/3/0/full.html)

A library for interacting with the [Analog Devices MAX17040 and MAX17041](https://www.analog.com/en/products/MAX17040.html) 1 and 2 cell lithium battery monitors over I2C.

## Usage

This library uses the [Wafer](https://harton.dev/james/wafer) project connect to the I2C device which means that it is independent of any specific I2C driver.

Example using [Elixir Circuits](https://hex.pm/packages/circuits_i2c)

    iex> {:ok, conn} = Wafer.Driver.CircuitsI2C.acquire(bus: "i2c-1", address: 0x36)
    ...> {:ok, conn} = Max1704x.acquire(conn)
    ...> Max1704x.current_voltage(conn)
    {:ok, 4.165}

## Installation

The `max1704x` package is [available on hex](https://hex.pm/packages/max1704x) so it can be installed by adding `max1704x` to your list of dependencies in `mix.exs`.

```elixir
def deps do
  [
    {:max1704x, "~> 0.1.0"}
  ]
end
```

Documentation for the latest release is always available on
[HexDocs](https://hexdocs.pm/max1704x/) and for the `main` branch
on [docs.harton.nz](https://docs.harton.nz/james/max1704x).

## Github Mirror

This repository is mirrored [on Github](https://github.com/jimsynz/max1704x)
from it's primary location [on my Forgejo instance](https://harton.dev/james/max1704x).
Feel free to raise issues and open PRs on Github.

## License

This software is licensed under the terms of the
[HL3-FULL](https://firstdonoharm.dev), see the `LICENSE.md` file included with
this package for the terms.

This license actively proscribes this software being used by and for some
industries, countries and activities. If your usage of this software doesn't
comply with the terms of this license, then [contact me](mailto:james@harton.nz)
with the details of your use-case to organise the purchase of a license - the
cost of which may include a donation to a suitable charity or NGO.
