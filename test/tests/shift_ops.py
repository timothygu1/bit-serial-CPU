import cocotb
from cocotb.triggers import ClockCycles
from tests.helpers import clock_init, reset, load_instruction, assert_result
import random

async def shift_ops(dut):
    await clock_init(dut, 10)
    await reset(dut)

    # Test Case 1
    val_r6 = random.randint(0, 255)
    shift_slli1 = random.randint(0, 7)
    shift_srli1 = random.randint(0, 7)
    dut._log.info(f"R6={hex(val_r6)}, SLLI by {shift_slli1}, SRLI by {shift_srli1}")

    # LOADI val_r6 -> STORE R6
    await load_instruction(dut, 0b00000111)
    await load_instruction(dut, val_r6)
    await load_instruction(dut, 0b01101110)
    await load_instruction(dut, 0x00)

    # SLLI r6, imm
    await load_instruction(dut, 0b01100010)
    await load_instruction(dut, shift_slli1)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, (val_r6 << shift_slli1) & 0xFF)

    # SRLI r6, imm
    await load_instruction(dut, 0b01100011)
    await load_instruction(dut, shift_srli1)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, val_r6 >> shift_srli1)

    # Test Case 2
    val_r5 = random.randint(0, 255)
    shift_slli2 = random.randint(0, 7)
    shift_srli2 = random.randint(0, 7)
    dut._log.info(f"R5={hex(val_r5)}, SLLI by {shift_slli2}, SRLI by {shift_srli2}")

    # LOADI val_r5 -> STORE R5
    await load_instruction(dut, 0b00000111)
    await load_instruction(dut, val_r5)
    await load_instruction(dut, 0b01011110)
    await load_instruction(dut, 0x00)

    # SLLI r5, imm
    await load_instruction(dut, 0b01010010)
    await load_instruction(dut, shift_slli2)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, (val_r5 << shift_slli2) & 0xFF)

    # SRLI r5, imm
    await load_instruction(dut, 0b01010011)
    await load_instruction(dut, shift_srli2)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, val_r5 >> shift_srli2)