# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles, ReadOnly

# to help in gd_test build
from cocotb.handle import SimHandleBase

def safe_get(dut: SimHandleBase, *paths: str) -> SimHandleBase:
    # Return the first handle that exists.  Works with or without Yosys flattening.
    for p in paths:
        try:
            return dut._id(p, extended=True)
        except (AttributeError, KeyError):
            continue
    raise AttributeError(f"None of {paths} found in DUT hierarchy")

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
    await ClockCycles(dut.clk, 1)
    dut.ui_in.value = byte
    await ClockCycles(dut.clk, 1)
    await pb0_press(dut)

async def get_acc(dut):
    # val = dut.user_project.u_cpu_core.acc.acc_bits.value
    # return val
    h = safe_get(dut,
                #  "user_project.u_cpu_core.acc.acc_bits",  # un‑flattened
                #  "user_project.acc_reg")                  # flattened (Yosys default)
                 "user_project.u_cpu_core.acc_dbg",  # un‑flattened
                 "user_project.u_cpu_core_acc_dbg")                  # flattened (Yosys default)
    await ReadOnly()
    return h.value.integer & 0xFF

async def get_reg(dut, reg):
    rs1  = safe_get(dut,
                    "user_project.u_cpu_core.regfile.rs1_addr",
                    "user_project.rs1_addr")
    data = safe_get(dut,
                    "user_project.u_cpu_core.regfile.regfile_bits",
                    "user_project.regfile_bits")
    rs1.value = reg
    await ReadOnly()
    return data.value.integer & 0xFF

async def assert_acc(dut, value):
    await ClockCycles(dut.clk, 3)
    acc_val = await get_acc(dut)
    dut._log.info(f"Accumulator bits: {acc_val} ({acc_val.integer})")

    assert acc_val == value, f"Expected {bin(value)}, got {bin(acc_val)}"

async def assert_reg(dut, reg, value):
    await ClockCycles(dut.clk, 2)
    reg_val = await get_reg(dut, reg)
    dut._log.info(f"R{reg} bits: {reg_val} ({reg_val.integer})")

    assert reg_val == value, f"Expected R{reg} = {bin(value)}, got {bin(reg_val)}"

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")
    
    # Set the clock period to 10 us (100 KHz)
    await clock_init(dut, 10)
    await reset(dut)
    dut._log.info("Test project behavior")

    
    # LOADI 0x2D
    await load_instruction(dut, 0b00000111)
    await load_instruction(dut, 0x2D)

    await assert_acc(dut, 0x2D)

    # STORE rs4
    await load_instruction(dut, 0b01001110)
    await load_instruction(dut, 0x00)

    await assert_reg(dut, 4, 0x2D)

    # LOADI 0x73
    await load_instruction(dut, 0b00000111)
    await load_instruction(dut, 0x73)

    await assert_acc(dut, 0x73)

    # STORE rs3
    await load_instruction(dut, 0b00111110)
    await load_instruction(dut, 0x00)

    await assert_reg(dut, 3, 0x73)

    # r4 = 0x2D = 45
    # r3 = 0x73 = 115

    # XOR r3, r4
    await load_instruction(dut, 0b00111100)
    await load_instruction(dut, 0x04)

    await ClockCycles(dut.clk, 10)
    
    # expected: 0x5E
    await assert_acc(dut, 0x5E)


    # AND r3, r4
    await load_instruction(dut, 0b00111011)
    await load_instruction(dut, 0x04)

    await ClockCycles(dut.clk, 10)

    # expected: 0x21
    await assert_acc(dut, 0x21)


    # ADD r3, r4
    await load_instruction(dut, 0b00111000)
    await load_instruction(dut, 0x04)

    await ClockCycles(dut.clk, 10)

    # expected: 0xA0 = 160
    await assert_acc(dut, 0xA0)


    # SUB r3, r4
    await load_instruction(dut, 0b00111001)
    await load_instruction(dut, 0x04)
    
    await ClockCycles(dut.clk, 10)

    # expected: 0x46 = 70
    await assert_acc(dut, 0x46)

    # Immediate instructions

    # ADDI r0 0x11
    await load_instruction(dut, 0b00000000)
    await load_instruction(dut, 0x11)
   
    await ClockCycles(dut.clk, 10)

    await assert_acc(dut, 0x11)


    # XORI r4 0x56
    await load_instruction(dut, 0b01000110)
    await load_instruction(dut, 0x56)

    await ClockCycles(dut.clk, 10)

    # expected: 0b00101101 ^ 0b01010110 = 0b01111011 = 0x7B
    await assert_acc(dut, 0x7B)

    # SUBI r3 0x2C
    await load_instruction(dut, 0b00110001)
    await load_instruction(dut, 0x2C)

    await ClockCycles(dut.clk, 10)
    #expected: 0x47
    await assert_acc(dut, 0x47)

    # SWAP R3 and R4:

    # LOAD R3
    await load_instruction(dut, 0b00111101)
    await load_instruction(dut, 0x00)

    # STORE R1
    await load_instruction(dut, 0b00011110)
    await load_instruction(dut, 0x00)

    # LOAD R4
    await load_instruction(dut, 0b01001101)
    await load_instruction(dut, 0x00)

    # STORE R3
    await load_instruction(dut, 0b00111110)
    await load_instruction(dut, 0x00)
    
    # LOAD R1
    await load_instruction(dut, 0b00011101)
    await load_instruction(dut, 0x00)

    # STORE R4
    await load_instruction(dut, 0b01001110)
    await load_instruction(dut, 0x00)

    await assert_reg(dut, 3, 0x2D)
    await assert_reg(dut, 4, 0x73)

    await ClockCycles(dut.clk, 10)


    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    dut._log.info("test")
    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
