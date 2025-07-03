# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    # Input first 8 instruction bits
    dut.ui_in.value = 20
    
    # Simulate button press to load instruction

    # Button is wired to uio_in[0]
    dut.uio_in.value = 0b00000000
    await ClockCycles(dut.clk, 1)

    # Simulate button press (1 cycle)
    dut.uio_in.value = 0b00000001  # Press (bit 0 = 1)
    await ClockCycles(dut.clk, 1)

    # Release button
    dut.uio_in.value = 0b00000000
    await ClockCycles(dut.clk, 1)

    # Input second 8 instruction bits
    dut.ui_in.value = 30
    await ClockCycles(dut.clk, 1)

    # Simulate button press (1 cycle)
    dut.uio_in.value = 0b00000001  # Press (bit 0 = 1)
    await ClockCycles(dut.clk, 1)

    # Release button
    dut.uio_in.value = 0b00000000
    await ClockCycles(dut.clk, 1)

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    #assert dut.uo_out.value == 50
    dut._log.info("test")
    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
