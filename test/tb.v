`default_nettype none
`timescale 1ns / 1ps

module tb ();

  // Dump the signals to a VCD file
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  // Clock and reset signals
  reg clk;
  reg rst_n;
  reg ena;
  
  // Inputs and outputs adapted for TinyTapeout
  reg [7:0] ui_in;  // Mapped to 'a' (lower 8 bits) and 'b' (upper 8 bits)
  reg [7:0] uio_in; // Mapped to PB (2 bits)
  wire [7:0] uo_out; // ALU results
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  // Instantiating the ALU module
  tt_um_alu_8bit_JorgeArias8644 user_project (
      .a      (ui_in[7:0]),  // Map 'a' to lower 8 bits of ui_in
      .b      (ui_in[15:8]), // Map 'b' to upper 8 bits of ui_in
      .PB     (uio_in[1:0]), // Map PB to 2 bits of uio_in
      .led    (uo_out)       // Output mapped to uo_out
  );

endmodule
