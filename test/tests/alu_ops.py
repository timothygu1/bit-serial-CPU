import cocotb
from cocotb.triggers import ClockCycles
from tests.helpers import clock_init, reset, load_instruction, assert_result

async def alu_ops(dut):
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

    # XOR R3, R4 -> expect 0x5E
    await load_instruction(dut, 0b00111100)
    await load_instruction(dut, 0x04)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, 0x5E)

    # AND R3, R4 -> expect 0x21
    await load_instruction(dut, 0b00111011)
    await load_instruction(dut, 0x04)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, 0x21)

    # ADD R3, R4 -> expect 0xA0
    await load_instruction(dut, 0b00111000)
    await load_instruction(dut, 0x04)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, 0xA0)

    # SUB R3, R4 -> expect 0x46
    await load_instruction(dut, 0b00111001)
    await load_instruction(dut, 0x04)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, 0x46)

    # OR R3, R4 -> expect 0x7F
    await load_instruction(dut, 0b00111010)
    await load_instruction(dut, 0x04)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, 0x7F)
