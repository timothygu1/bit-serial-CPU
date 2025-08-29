import cocotb
from cocotb.triggers import ClockCycles
from tests.helpers import clock_init, reset, load_instruction, assert_result
import random

async def alu_ops(dut):
    await clock_init(dut, 10)
    await reset(dut)

    # Generate random 8-bit values
    val_r4 = random.randint(0, 255)
    val_r3 = random.randint(0, 255)

    dut._log.info(f"R4={hex(val_r4)}, R3={hex(val_r3)}")

    # LOADI val_r4 to acc, STORE R4
    await load_instruction(dut, 0b00000111)
    await load_instruction(dut, val_r4)
    await load_instruction(dut, 0b01001110)
    await load_instruction(dut, 0x00)

    # LOADI val_r3 to acc, STORE R3
    await load_instruction(dut, 0b00000111)
    await load_instruction(dut, val_r3)
    await load_instruction(dut, 0b00111110)
    await load_instruction(dut, 0x00)

    # XOR R3, R4
    await load_instruction(dut, 0b00111100)
    await load_instruction(dut, 0x04)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, val_r3 ^ val_r4)

    # AND R3, R4
    await load_instruction(dut, 0b00111011)
    await load_instruction(dut, 0x04)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, val_r3 & val_r4)

    # ADD R3, R4
    await load_instruction(dut, 0b00111000)
    await load_instruction(dut, 0x04)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, (val_r3 + val_r4) & 0xFF) # Use & 0xFF for 8-bit wraparound

    # SUB R3, R4
    await load_instruction(dut, 0b00111001)
    await load_instruction(dut, 0x04)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, (val_r3 - val_r4) & 0xFF) # Use & 0xFF for 8-bit wraparound

    # OR R3, R4
    await load_instruction(dut, 0b00111010)
    await load_instruction(dut, 0x04)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, val_r3 | val_r4)