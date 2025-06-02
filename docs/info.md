

## How it works

This project implements an 8-bit Arithmetic Logic Unit (ALU) using Verilog. The ALU performs basic operations on two 8-bit inputs (a and b), controlled by a 2-bit signal (PB).
Each bit operation is handled by an alu_1bit module, which processes bitwise AND, OR, inversion, and arithmetic addition using a Carry Lookahead Adder (CLA). The ALU’s output (led) reflects the computed results, displayed on the Basys 3 LEDs


## How to test

To test the project on the Basys 3 FPGA:
- Configure the input switches:
- Assign the first 8 switches (SW0-SW7) to a.
- Assign the next 8 switches (SW8-SW15) to b.
- Assign the function selector (PB) to SW16-SW17.
- Compile and upload the design:
- Open Vivado and synthesize the Verilog code.
- Generate the bitstream file and upload it to the Basys 3 FPGA via USB.
- Observe the output:
- The 8 onboard LEDs display the ALU results (led).
- Change the values of a, b, and PB using the switches to test different operations.


## External hardware

- Basys 3 FPGA Board
- Onboard LEDs (used to display the ALU result)
- Onboard switches (used for a, b, and operation selection)

