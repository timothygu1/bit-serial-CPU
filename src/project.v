/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_cpu_top (
    input  wire [7:0] ui_in,    // Inputs for instruction data (through DIP switches)
    output wire [7:0] uo_out,   // Outputs to drive LEDs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out = 0;
  assign uio_oe  = 0;

  reg [3:0] opcode;
  reg [11:0] instr;
  reg bit_count;

  // parallel load instructions into instr reg

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin // Reset
        instr <= 12'b0;
        bit_count <= 0;
    end else if (uio_in[0]) begin // Load if PB is pressed
        case (bit_count) // Starting a new instruction
            0: begin
                opcode <= ui_in[3:0];
                instr[3:0] <= ui_in[7:4];
                bit_count <= 1;
            end
            1: begin    // Second half of instruction
                instr[11:4] <= ui_in; // then MSB
                bit_count <= 0;       // loading complete
            end
        endcase
    end
end


  /*
  IDEAS IN PROGRESS:
  S_IDLE should display a status on the 7-seg display on the demo board. Perhaps a letter indicating the expected next input
    ('L' for lower 8 bits, 'H' for upper 8 bits)
  


   */

  // Button edge-detector and synchronizer 

  reg btn_sync0, btn_sync1, btn_prev;
  wire btn_level = uio_in[0]; // external push button
  wire btn_edge = btn_sync1 & ~btn_prev; // detect rising edge

  // always @(posedge clk or negedge rst_n) begin
  //   if (!rst_n) begin
  //     btn_sync0 <= 1'b1; // assume pull-up idle high
  //     btn_sync1 <= 1'b1;
  //     btn_prev <= 1'b1;
  //   end else begin
  //     btn_sync0 <= btn_level;
  //     btn_sync1 <= btn_sync0;
  //     btn_prev <= btn_sync1;
  //   end
  // end

  // FSM states

  typedef enum logic [2:0] {
    S_RESET, // TODO is this needed, or do we use built-in rst_n instead?
    S_IDLE, // waiting for button press to shift in instruction bit values from DIP switches
    S_FETCH_LO, // capture lower 8 instruction bits
    S_FETCH_HI, // capture upper 8 instruction bits
    S_EXECUTE // perform 
  } state_t;

  state_t state, next_state;

  // datapath control signals and serial wires

  reg le; // load enable for shift registers 
  reg ae; // accumulate enable for ALU
  wire serial_in; // single bit serial input into ALU
  wire serial_out; // single bit serial output from ALU

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule
