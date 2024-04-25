defmodule Max1704xTest do
  @moduledoc false
  use ExUnit.Case
  doctest Max1704x
  use Mimic
  alias Max1704x.Registers

  setup do
    conn = %Wafer.Driver.Fake{}

    {:ok, conn: conn}
  end

  describe "acquire/1" do
    test "when the `conn` is not passed, it returns an error" do
      assert {:error, error} = Max1704x.acquire(variant: :max17040)
      assert Exception.message(error) =~ ~r/required :conn option not found/
    end

    test "when the `variant` value is invalid, it returns an error", %{conn: conn} do
      assert {:error, error} = Max1704x.acquire(conn: conn, variant: :marty)
      assert Exception.message(error) =~ ~r/expected one of \[:max17040, :max17041\]/
    end
  end

  describe "current_voltage/1" do
    test "when the variant is :max17040 it returns the correct value", %{conn: conn} do
      {:ok, conn} = Max1704x.acquire(conn: conn, variant: :max17040)

      Registers
      |> expect(:read_vcell, fn _conn ->
        {:ok, <<0xCE, 0x40>>}
      end)

      assert {:ok, 4.125} = Max1704x.current_voltage(conn)
    end

    test "when the variant is :max17041 it returns the correct value", %{conn: conn} do
      {:ok, conn} = Max1704x.acquire(conn: conn, variant: :max17041)

      Registers
      |> expect(:read_vcell, fn _conn ->
        {:ok, <<0xCE, 0x40>>}
      end)

      assert {:ok, 8.25} = Max1704x.current_voltage(conn)
    end
  end

  describe "current_charge/1" do
    test "it returns the correct value from the SOC register", %{conn: conn} do
      {:ok, conn} = Max1704x.acquire(conn: conn, variant: :max17041)

      Registers
      |> expect(:read_soc, fn _conn ->
        {:ok, <<0x62, 0xA0>>}
      end)

      assert {:ok, 98.625} = Max1704x.current_charge(conn)
    end
  end

  describe "quickstart!/1" do
    test "it sends the correct command to the MODE register", %{conn: conn} do
      {:ok, conn} = Max1704x.acquire(conn: conn, variant: :max17041)

      Registers
      |> expect(:write_mode, fn conn, value ->
        assert <<0x40, 0x00>> = value
        {:ok, conn}
      end)

      assert {:ok, _} = Max1704x.quickstart!(conn)
    end
  end

  describe "power_on_reset!/1" do
    test "it sends the correct command to the COMMAND register", %{conn: conn} do
      {:ok, conn} = Max1704x.acquire(conn: conn, variant: :max17041)

      Registers
      |> expect(:write_command, fn conn, value ->
        assert <<0x00, 0x54>> = value
        {:ok, conn}
      end)

      assert {:ok, _} = Max1704x.power_on_reset!(conn)
    end
  end

  describe "version/1" do
    test "it returns the correct value", %{conn: conn} do
      {:ok, conn} = Max1704x.acquire(conn: conn, variant: :max17041)

      Registers
      |> expect(:read_version, fn _conn ->
        {:ok, <<0x00, 0x02>>}
      end)

      assert {:ok, 2} = Max1704x.version(conn)
    end
  end

  describe "compensation/1" do
    test "it returns the correct value", %{conn: conn} do
      {:ok, conn} = Max1704x.acquire(conn: conn, variant: :max17041)

      Registers
      |> expect(:read_rcomp, fn _conn ->
        {:ok, <<0xAB, 0xCD>>}
      end)

      assert {:ok, 0xABCD} = Max1704x.compensation(conn)
    end
  end

  describe "compensation/2" do
    test "it writes the correct value to the compenstaion register", %{conn: conn} do
      {:ok, conn} = Max1704x.acquire(conn: conn, variant: :max17041)

      Registers
      |> expect(:write_rcomp, fn conn, value ->
        assert <<0xAB, 0xCD>> = value

        {:ok, conn}
      end)

      assert {:ok, _conn} = Max1704x.compensation(conn, 0xABCD)
    end
  end
end
