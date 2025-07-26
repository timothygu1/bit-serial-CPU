import cocotb
from cocotb.triggers import ClockCycles
from tests.helpers import clock_init, reset, load_instruction, assert_result

async def imm_alu_ops(dut):
    await clock_init(dut, 10)
    await reset(dut)

    # LOADI 0x2D to acc, STORE R4
    await load_instruction(dut, 0b00000111)
    await load_instruction(dut, 0x2D)
    await load_instruction(dut, 0b01001110)
    await load_instruction(dut, 0x00)

    # LOADI 0x73 to acc, STORE R3
    await load_instruction(dut, 0b00000111)
    await load_instruction(dut, 0x73)
    await load_instruction(dut, 0b00111110)
    await load_instruction(dut, 0x00)

    # ADDI r0, 0x11 -> expect 0x11
    await load_instruction(dut, 0b00000000)
    await load_instruction(dut, 0x11)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, 0x11)

    # XORI r4, 0x56 -> r4 = 0x2D -> expect 0x7B
    await load_instruction(dut, 0b01000110)
    await load_instruction(dut, 0x56)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, 0x7B)

    # SUBI r3, 0x2C -> r3 = 0x73 -> expect 0x47
    await load_instruction(dut, 0b00110001)
    await load_instruction(dut, 0x2C)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, 0x47)

    # ANDI r3, 0x77 -> r3 = 0x73 -> expect 0x73 & 0x77 = 0x73
    await load_instruction(dut, 0b00110101)
    await load_instruction(dut, 0x77)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, 0x73)

    # ORI r3, 0x08 -> r3 = 0x73 -> expect 0x73 | 0x08 = 0x7B
    await load_instruction(dut, 0b00110100)
    await load_instruction(dut, 0x08)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, 0x7B)

