import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


async def clock_init(dut, useconds=10):
    clock = Clock(dut.clk, useconds, units="us")
    cocotb.start_soon(clock.start())


async def reset(dut):
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)


async def pb0_press(dut):
    dut.uio_in.value = 1
    await ClockCycles(dut.clk, 2)
    dut.uio_in.value = 0
    await ClockCycles(dut.clk, 1)


async def load_instruction(dut, byte):
    await ClockCycles(dut.clk, 1)
    dut.ui_in.value = byte
    await ClockCycles(dut.clk, 1)
    await pb0_press(dut)


async def assert_result(dut, expected):
    await ClockCycles(dut.clk, 3)
    actual = dut.uo_out.value
    assert actual == expected, f"Expected {bin(expected)}, got {bin(actual)}"
    dut._log.info(f"Output = {bin(actual)}")
