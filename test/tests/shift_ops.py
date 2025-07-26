import cocotb
from cocotb.triggers import ClockCycles
from tests.helpers import clock_init, reset, load_instruction, assert_result

async def shift_ops(dut):
    await clock_init(dut, 10)
    await reset(dut)

    # LOADI 0x12 -> STORE R6
    await load_instruction(dut, 0b00000111)
    await load_instruction(dut, 0x12)
    await load_instruction(dut, 0b01101110)
    await load_instruction(dut, 0x00)

    # SLLI r6, 0x02 -> expect 0x48
    await load_instruction(dut, 0b01100010)
    await load_instruction(dut, 0x02)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, 0x48)

    # SRLI r6, 0x01 -> expect 0x09
    await load_instruction(dut, 0b01100011)
    await load_instruction(dut, 0x01)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, 0x09)

    # LOADI 0xF0 -> STORE R5
    await load_instruction(dut, 0b00000111)
    await load_instruction(dut, 0xF0)
    await load_instruction(dut, 0b01011110)
    await load_instruction(dut, 0x00)

    # SLLI r5, 0x01 -> expect 0xE0
    await load_instruction(dut, 0b01010010)
    await load_instruction(dut, 0x01)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, 0xE0)

    # SRLI r5, 0x04 -> expect 0x0F
    await load_instruction(dut, 0b01010011)
    await load_instruction(dut, 0x04)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, 0x0F)
