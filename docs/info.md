<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

A bit-serial CPU processes one bit of a data word at a time using minimal logic - often reusing a small ALU and control unit across clock cycles. This is in contrast to a bit-parallel CPU, which processes entire data words (e.g., 8/16/32 bits) at once.

### Block Diagram
![298A Block Diagram](https://github.com/user-attachments/assets/b3a920e7-caca-4666-9459-7a705585725b)

### Todo: Explanation of architecture
- Register file
- Bit-serial ALU
- Accumulator register
- Control FSM
- Functional use (button press, instructions loaded over 2 cycles)

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


## How to test

TBD: Add this section