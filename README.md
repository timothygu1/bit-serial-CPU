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
| Opcode | Mnemonic | Description                    |
| ------ | -------- | ------------------------------ |
| `0000` | `NOP`    | Do nothing                     |
| `0001` | `LOAD_A` | Load value into A              |
| `0010` | `LOAD_B` | Load value into B              |
| `0011` | `ADD`    | A + B → OUT                    |
| `0100` | `XOR`    | A ^ B → OUT                    |
| `0101` | `AND`    | A & B → OUT                    |
| `0110` | `SHL`    | A << 1 (bit-serial shift left) |
| `0111` | `SHR`    | A >> 1                         |
| `1000` | `OUTPUT` | Move result to output register |


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
