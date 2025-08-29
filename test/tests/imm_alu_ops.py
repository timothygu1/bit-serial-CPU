import cocotb
from cocotb.triggers import ClockCycles
from tests.helpers import clock_init, reset, load_instruction, assert_result
import random

async def imm_alu_ops(dut):
    await clock_init(dut, 10)
    await reset(dut)

    # Generate random 8-bit values for registers
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

    # ADDI r0, imm
    imm_add = random.randint(0, 255)
    await load_instruction(dut, 0b00000000)
    await load_instruction(dut, imm_add)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, imm_add) # r0 is likely 0, so result is just the immediate

    # XORI r4, imm
    imm_xor = random.randint(0, 255)
    await load_instruction(dut, 0b01000110)
    await load_instruction(dut, imm_xor)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, val_r4 ^ imm_xor)

    # SUBI r3, imm
    imm_sub = random.randint(0, 255)
    await load_instruction(dut, 0b00110001)
    await load_instruction(dut, imm_sub)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, (val_r3 - imm_sub) & 0xFF)

    # ANDI r3, imm
    imm_and = random.randint(0, 255)
    await load_instruction(dut, 0b00110101)
    await load_instruction(dut, imm_and)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, val_r3 & imm_and)

    # ORI r3, imm
    imm_or = random.randint(0, 255)
    await load_instruction(dut, 0b00110100)
    await load_instruction(dut, imm_or)
    await ClockCycles(dut.clk, 10)
    await assert_result(dut, val_r3 | imm_or)