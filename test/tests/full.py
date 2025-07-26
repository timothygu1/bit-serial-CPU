# test/test_full_program.py

import cocotb
from cocotb.triggers import ClockCycles
from tests.helpers import clock_init, reset, load_instruction, assert_result
from tests.alu_ops import alu_ops
from tests.imm_alu_ops import imm_alu_ops
from tests.shift_ops import shift_ops

@cocotb.test()
async def test_alu_ops(dut):
    await alu_ops(dut)

@cocotb.test()
async def test_imm_alu_ops(dut):
    await imm_alu_ops(dut)

@cocotb.test()
async def test_shift_ops(dut):
    await shift_ops(dut)

@cocotb.test()
async def test_full(dut):
    dut._log.info("Starting full integration test")
    await clock_init(dut)
    await reset(dut)

    # LOADI 0x2D
    await load_instruction(dut, 0b00000111)
    await load_instruction(dut, 0x2D)
    await assert_result(dut, 0x2D)

    # STORE r4
    await load_instruction(dut, 0b01001110)
    await load_instruction(dut, 0x00)

    # LOADI 0x73
    await load_instruction(dut, 0b00000111)
    await load_instruction(dut, 0x73)
    await assert_result(dut, 0x73)

    # STORE r3
    await load_instruction(dut, 0b00111110)
    await load_instruction(dut, 0x00)

    # LOADI 0x0A
    await load_instruction(dut, 0b00000111)
    await load_instruction(dut, 0x0A)
    await assert_result(dut, 0x0A)

    # STORE r7
    await load_instruction(dut, 0b01111110)
    await load_instruction(dut, 0x00)

    # XOR r3, r4
    await load_instruction(dut, 0b00111100)
    await load_instruction(dut, 0x04)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, 0x5E)

    # AND r3, r4
    await load_instruction(dut, 0b00111011)
    await load_instruction(dut, 0x04)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, 0x21)

    # ADD r3, r4
    await load_instruction(dut, 0b00111000)
    await load_instruction(dut, 0x04)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, 0xA0)

    # SUB r3, r4
    await load_instruction(dut, 0b00111001)
    await load_instruction(dut, 0x04)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, 0x46)

    # ADDI r0, 0x11
    await load_instruction(dut, 0b00000000)
    await load_instruction(dut, 0x11)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, 0x11)

    # XORI r4, 0x56
    await load_instruction(dut, 0b01000110)
    await load_instruction(dut, 0x56)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, 0x7B)

    # SUBI r3, 0x2C
    await load_instruction(dut, 0b00110001)
    await load_instruction(dut, 0x2C)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, 0x47)

    # SLLI r7, 0x03
    await load_instruction(dut, 0b01110010)
    await load_instruction(dut, 0x03)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, 0x50)

    # SRLI r7, 0x01
    await load_instruction(dut, 0b01110011)
    await load_instruction(dut, 0x01)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, 0x05)

    # SWAP R3 and R4
    await load_instruction(dut, 0b00111101)  # LOAD R3
    await load_instruction(dut, 0x00)
    await load_instruction(dut, 0b00011110)  # STORE R1
    await load_instruction(dut, 0x00)
    await load_instruction(dut, 0b01001101)  # LOAD R4
    await load_instruction(dut, 0x00)
    await load_instruction(dut, 0b00111110)  # STORE R3
    await load_instruction(dut, 0x00)
    await load_instruction(dut, 0b00011101)  # LOAD R1
    await load_instruction(dut, 0x00)
    await load_instruction(dut, 0b01001110)  # STORE R4
    await load_instruction(dut, 0x00)

    # Final value should now be: R3 = 0x2D, R4 = 0x73
    await load_instruction(dut, 0b01001101)  # LOAD R4
    await load_instruction(dut, 0x00)
    await assert_result(dut, 0x73)

    await load_instruction(dut, 0b00111101)  # LOAD R3
    await load_instruction(dut, 0x00)
    await assert_result(dut, 0x2D)

    dut._log.info("Full program test completed")