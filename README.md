![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# 8-Bit-Serial CPU

- [Read the documentation for project](docs/info.md)

## Introduction

This project implements a compact bit-serial CPU in Verilog submitted to Tiny Tapeout, an open-source ASIC shuttle program that enables small digital designs to be fabricated on a shared silicon die. The CPU is designed to fit within a 160 x 100 μm footprint.

A bit-serial CPU processes one bit of a data word at a time using minimal logic - often reusing a small ALU and control unit across clock cycles. This is in contrast to a bit-parallel CPU, which processes entire data words (e.g., 8/16/32 bits) at once.

## Initial Specifications
### TinyTapeout Signals
| Pin Group	| Type |	Usage |
| --------- | ---- | ------ |
| load[7:0] |	Input	| Value to load to register |
| opcode[3:0]	 | Bidirectional | 4-bit instruction opcode |
| out[7:0] | Output |	Parallel output |
| clk |	Clock |	clock input |
| rst	| Reset |	reset FSM and registers |

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


### **Control FSM**

**Purpose**: Decodes the instruction and orchestrates sequencing of steps.

**Outputs**: Control signals

- `load_a`, `load_b`, `shift_a, shift_b`, `shift_out`,
- `alu_op[1:0]` (e.g., `00 = ADD`, `01 = XOR`, etc.)
- Internal state: `IDLE`, `LOAD_A`, `LOAD_B`, `EXECUTE`, `WRITE_OUT`

### **Shift Registers** (for A, B, and OUT)

**Purpose**: Store and serially shift bits in/out.

Functionality:

- **Parallel load** (for registers A & B, to take in `load[7:0]`)
- **Serial shift** **right**
    - for A and B, this exposes the LSB to ALU operations
    - for OUT, this shifts in each 1-bit result from ALU
- **Clear/reset**

**Inputs:**

Data:

- load[7:0] (A and B)
- alu_result (OUT)

Control signals:

- load_a, load_b
- shift_a, shift_b, shift_out

### **1-Bit ALU**

**Purpose**: Perform 1-bit logic/math based on A, B, and carry.

Inputs:

- `a_bit`, `b_bit`, `carry_in`, `alu_op[1:0]`

Outputs:

- `alu_result`, `carry_out` (saved in 1-bit register)

### **8-Bit Counter**

**Purpose**: Keeps track of how many bits have been processed.

Tells FSM when to advance (after 8 bits done).

### Block Diagram
![298A Block Diagram](https://github.com/user-attachments/assets/b3a920e7-caca-4666-9459-7a705585725b)


## TinyTapeout User Instructions
### Set up your Verilog project

1. Add your Verilog files to the `src` folder.
2. Edit the [info.yaml](info.yaml) and update information about your project, paying special attention to the `source_files` and `top_module` properties. If you are upgrading an existing Tiny Tapeout project, check out our [online info.yaml migration tool](https://tinytapeout.github.io/tt-yaml-upgrade-tool/).
3. Edit [docs/info.md](docs/info.md) and add a description of your project.
4. Adapt the testbench to your design. See [test/README.md](test/README.md) for more information.

The GitHub action will automatically build the ASIC files using [OpenLane](https://www.zerotoasiccourse.com/terminology/openlane/).

### Enable GitHub actions to build the results page

- [Enabling GitHub Pages](https://tinytapeout.com/faq/#my-github-action-is-failing-on-the-pages-part)

### Resources

- [FAQ](https://tinytapeout.com/faq/)
- [Digital design lessons](https://tinytapeout.com/digital_design/)
- [Learn how semiconductors work](https://tinytapeout.com/siliwiz/)
- [Join the community](https://tinytapeout.com/discord)
- [Build your design locally](https://www.tinytapeout.com/guides/local-hardening/)

### What next?

- [Submit your design to the next shuttle](https://app.tinytapeout.com/).
- Edit [this README](README.md) and explain your design, how it works, and how to test it.
- Share your project on your social network of choice:
  - LinkedIn [#tinytapeout](https://www.linkedin.com/search/results/content/?keywords=%23tinytapeout) [@TinyTapeout](https://www.linkedin.com/company/100708654/)
  - Mastodon [#tinytapeout](https://chaos.social/tags/tinytapeout) [@matthewvenn](https://chaos.social/@matthewvenn)
  - X (formerly Twitter) [#tinytapeout](https://twitter.com/hashtag/tinytapeout) [@tinytapeout](https://twitter.com/tinytapeout)
