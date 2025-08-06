<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

A bit-serial CPU processes one bit of a data word at a time using minimal logic - often reusing a small ALU and control unit across clock cycles. This is in contrast to a bit-parallel CPU, which processes entire data words (e.g., 8/16/32 bits) at once.

Processing a single bit at a time instead of in parallel means that the CPU is much slower, but it can be made much smaller. This makes the bit-serial architecture very suitable for a submission to TinyTapeout in which a chip area of 160 x 100 μm is one of the primary constraints.

In this design, 16-bit width instructions are fed into the CPU over two clock cycles using the 8 TinyTapeout input signals. These instructions are decoded and the relevant operands (either immediates or stored values from a register file) are processed bit-serially from LSB to MSB and shifted into an accumulator register. The CPU supports parallel load operations to the accumulator and storing results from the accumulator to an addressable register file.

##  Functional Use (Instruction Loading)

### Instruction Set
| Opcode | Mnemonic | C Operation                    | Description |
| ------ | -------- | ------------------------------ | ----------- |
| `0000` | `ADDI`    | acc = rs1 + imm                   | Add Immediate|
| `0001` | `SUBI`    | acc = rs1 - imm                   | Subtract Immediate |
| `0010` | `SLLI`      | acc = rs1 << imm        | Shift left Immediate      |
| `0011` | `SRLI`      | acc = rs1 >> imm        | Shift right Immediate    |
| `0100` | `ORI` | acc = rs1 \| imm             | Bitwise OR Immediate |
| `0101` | `ANDI` | acc = rs1 & imm             | Bitwise AND Immediate |
| `0110` | `XORI`    | acc = rs1 ^ imm                    | Bitwise Exclusive OR Immediate |
| `0111` | `LOADI`      | acc = imm        | Load immediate into accumulator    |
| `1000` | `ADD`    | acc = rs1 + rs2                   | Add Registers |
| `1001` | `SUB`    | acc = rs1 - rs2                   | Subtract Registers |
| `1010` | `OR` | acc = rs1 \| rs2              | Bitwise OR Registers |
| `1011` | `AND` | acc = rs1 & rs2              | Bitwise AND Registers |
| `1100` | `XOR`    | acc = rs1 ^ rs2                    | Bitwise Exclusive OR Registers |
| `1101` | `LOAD`      | acc = rs1        | Load from register into accumulator    |
| `1110` | `STORE`      | rs1 = acc        | Store from accumulator into register    |

### TinyTapeout Signals Used
| Pin Group	| Type |	Usage |
| --------- | ---- | ------ |
| ui_in[7:0] |	Input	| Instruction bit inputs |
| uio_in[0] |	Bidirectional	| Pushbutton input for instruction loading |
| uo_out[7:0] | Output |	Parallel output |
| clk |	Clock |	Clock input |
| rst_n	| Reset |	Active low synchronous reset |

### 16-bit Instruction Bit Fields

#### I-Type (opcode[3] == 0)
| [15:8] | [7] | [6:4]| [3:0] |
| --- | --- |--- | --- |
| immediate[7:0] |unused| rs1_addr[2:0] | opcode[3:0] |

#### R-Type (opcode[3] == 1)
| [15:11] | [10:7] | [6:4]| [3:0] |
| --- | --- |--- | --- |
| unused | rs2_addr | rs1_addr[2:0] | opcode[3:0] |

Instructions are loaded manually over two clock cycles via button press:

First press:
- Lower 4 bits (`ui_in[3:0]`) are latched into `opcode[3:0]`
- Upper 4 bits (`ui_in[7:4]`) go into `instr[3:0]`
- `inst_done` is set high

Second press:
- `ui_in[7:0]` fills in `instr[11:4]`
- `inst_done` is cleared

An edge-detected pushbutton (connected via `uio_in[0]`) triggers instruction loading. Once loaded, the FSM executes the instruction, and the final result is output on `uo_out[7:0]`.

## Architecture

### Block Diagram
<img width="2719" height="1014" alt="image" src="https://github.com/user-attachments/assets/c0e4eb80-4685-4eb3-b876-7a634d39eb94" />

#### Control FSM
The `fsm_control` module orchestrates datapath sequencing using a 5-state FSM:

1. `S_IDLE`: Waits for button press and valid instruction

2. `S_DECODE`: Decodes opcode, issues control signals for load/store/ALU

3. `S_SHIFT_REGS`: Performs serial operations; enables register shifting and accumulator writes

4. `S_WRITE_ACC`: Special case state for direct writes (not commonly used)

5. `S_OUTPUT`: Signals end of execution and enables writing to output LEDs

The FSM generates control signals including  `reg_shift_en`, `acc_write_en`, `alu_start`, `alu_op`, and `out_e`n based on instruction type.

#### Register File
The regfile_serial module implements an 8×8 register file, where each register is 8 bits wide. It supports:
- Serial read: each clock cycle, the bit_index increments, allowing serial bit access.
- Parallel write: a whole 8-bit register is overwritten at once from the accumulator.
- Shift operations: for shift-left/right immediate `(SLLI/SRLI)`, rs1_bit is offset by shift_imm, computed from `instr[6:4]`.

The register file outputs:
- `rs1_bit`: used as ALU operand 1
- `rs2_bit`: used as ALU operand 2 (only valid for R-type)
- `regfile_bits`: parallel content of the selected rs1 register, for `LOAD/LOADI`

#### Bit-Serial ALU
The alu_1bit module performs a one-bit computation per cycle based on alu_op:
- Supports operations: `ADD`, `SUB`, `XOR`, `AND`, `OR`, pass-through (for shift ops).
- `carry_in` and `carry_out` are managed explicitly to support serial arithmetic.
- For `SUB`, `rs2` is inverted and an initial carry is injected on the first cycle.

The ALU receives `rs1`, `rs2`, `alu_op`, `alu_start`, and outputs a single-bit result to the accumulator.

#### Accumulator Register
The accumulator is an 8-bit shift register that:
- Loads data in parallel from `regfile_bits` or `instr[11:4]` (based on `opcode[3]`)
- Receives ALU output one bit at a time via `alu_result`
- Tracks the write index using a delayed `bit_index_d` signal to update the correct bit and signals completion when done

The accumulator provides the final output via `acc_bits`.


## Test Plan
This project uses a black-box testing strategy to validate the behavior of the bit-serial CPU. 

- **Inputs**: Sequences of instructions are applied to the design via `ui_in[7:0]` and a simulated pushbutton `uio_in[0]`.
- **Outputs**: `uo_out[7:0]` is compared against the expected result to determine if the CPU gives the correct output.
- **Clock and Reset**: Controlled via `clk` and `rst_n`.

This is a clean abstraction of test logic that reflects the real-world usage model of the CPU with portability to gate-level simulations.

A cocoTB testbench is used to run tests in Python. Each test uses the following structure:

1. Begin by starting the system clock and asserting/deasserting reset.
2. Instructions are loaded using simulated button presses. After an instruction load, insert a delay matching the bit-serial ALU's processing time (via await ClockCycles(...)) before giving the next instruction.
3. Compare `uo_out` against the expected result using `assert_result(...)`. A test fails if the result mismatches or the CPU fails to update the output.

### Test Coverage

| Instructions Used                             | Test File                                       | Testing Strategy |
| ------------------------------------ | -------------------------------------------------- | ----- |
| `ADD`, `SUB`, `AND`, `OR`, `XOR`, `LOADI`, `STORE`      | [`test/tests/alu_ops.py`](https://github.com/timothygu1/bit-serial-CPU/blob/a4838efc1c192e5c24428fe590310855518c1b8a/test/tests/alu_ops.py) | Load known values into registers, execute all R-type instructions using those registers, and assert expected results |
| `ADDI`, `SUBI`, `ANDI`, `ORI`, `XORI`, `LOADI`, `STORE` | [`test/tests/imm_alu_ops.py`](https://github.com/timothygu1/bit-serial-CPU/blob/a4838efc1c192e5c24428fe590310855518c1b8a/test/tests/imm_alu_ops.py) | Load known values into registers, execute all I-type instructions using stored values along with immediates, and assert expected results |
| `SLLI`, `SRLI`, `LOADI`, `STORE`         | [`test/tests/shift_ops.py`](https://github.com/timothygu1/bit-serial-CPU/blob/a4838efc1c192e5c24428fe590310855518c1b8a/test/tests/shift_ops.py) | Load known values into a register and perform left shift and right shift using different shift amounts |
| All instructions                 | [`test/tests/full.py`](https://github.com/timothygu1/bit-serial-CPU/blob/a4838efc1c192e5c24428fe590310855518c1b8a/test/tests/full.py)| Full integration test including the entire instruction set |

#### Features validated implicitly from result correctness:
- Accumulator shifting
- Bit-serial ALU operations
- Register file read/write logic
- FSM transitions and timing
