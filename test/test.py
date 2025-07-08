# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles


async def clock_init(dut, useconds):
    clock = Clock(dut.clk, useconds, units="us")
    cocotb.start_soon(clock.start())

async def reset(dut):
    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)

async def pb0_press(dut):
    # Simulate a 1-cycle button press
    dut.uio_in.value = 1
    await ClockCycles(dut.clk, 2)
    dut.uio_in.value = 0
    await ClockCycles(dut.clk, 1)

async def load_instruction(dut, byte):
    # Load 8 bits of an instruction
    dut.ui_in.value = byte
    await ClockCycles(dut.clk, 1)
    await pb0_press(dut)

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")
    
    # Set the clock period to 10 us (100 KHz)
    await clock_init(dut, 10)

    await reset(dut)

    dut._log.info("Test project behavior")

    # Input first 8 instruction bits
    await load_instruction(dut, 0x32)

    # Input second 8 instruction bits
    await load_instruction(dut, 0x04)

    await ClockCycles(dut.clk, 30)

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    dut._log.info("test")
    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
