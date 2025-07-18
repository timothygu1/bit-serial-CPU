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

# async def preload_regfile(dut, reg_values):
#     """Load each register in regfile_serial with dummy data."""
#     for reg_index, value in enumerate(reg_values):
#         dut.user_project.u_cpu_core.regfile.rs1_addr.value = reg_index
#         await load_register(dut, reg_index, value)

# async def test_fill_regfile(dut):
#     # Fill all 8 registers with dummy data (example: 0xA0, 0xB1, etc.)
#     dummy_data = [0xA0, 0xB1, 0xC2, 0xD3, 0xE4, 0xF5, 0x16, 0x27]
#     await preload_regfile(dut, dummy_data)

#     dut._log.info("All registers loaded with test data")

# async def load_register(dut, index, value):
#     dut.user_project.u_cpu_core.regfile.rs1_addr.value = index
    
#     for bit_index in range(8):
#             # Write LSB first
#             dut.user_project.u_cpu_core.regfile.wr_bit.value = (value >> bit_index) & 1
#             dut.user_project.u_cpu_core.regfile.wr_en.value = 1
#             await ClockCycles(dut.clk, 1)

#     dut.user_project.u_cpu_core.regfile.wr_en.value = 0  # Clean up

#async def load_accumulator()


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")
    
    # Set the clock period to 10 us (100 KHz)
    await clock_init(dut, 10)

    await reset(dut)

    # await test_fill_regfile(dut)

    dut._log.info("Test project behavior")


    # await load_register(dut, 4, 0b00101101)

    # await load_register(dut, 3, 0b01110011)

    # LOADI 0x2D
    await load_instruction(dut, 0b00000111)
    await load_instruction(dut, 0x2D)

    # STORE rs4
    await load_instruction(dut, 0b01001110)
    await load_instruction(dut, 0x00)

    # LOADI 0x73
    await load_instruction(dut, 0b00000111)
    await load_instruction(dut, 0x73)

    # STORE rs3

    await load_instruction(dut, 0b00111110)
    await load_instruction(dut, 0x00)

    # r4 = 0x2D = 45
    # r3 = 0x73 = 115

    # XOR r3, r4
    await load_instruction(dut, 0b00111100)
    await load_instruction(dut, 0x04)

    # expected: 0x5E

    await ClockCycles(dut.clk, 10)

    # AND r3, r4
    await load_instruction(dut, 0b00111011)
    await load_instruction(dut, 0x04)

    # expected: 0x21

    await ClockCycles(dut.clk, 10)

    # ADD r3, r4
    await load_instruction(dut, 0b00111000)
    await load_instruction(dut, 0x04)

    await ClockCycles(dut.clk, 10)

    # expected: 0xA0 = 160

    # SUB r3, r4
    await load_instruction(dut, 0b00111001)
    await load_instruction(dut, 0x04)

    # expected: 0x46 = 70

    await ClockCycles(dut.clk, 50)

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    dut._log.info("test")
    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
