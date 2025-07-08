// regfile_serial.v

`default_nettype none

module regfile_serial #(
    parameter REG_WIDTH = 8,
    parameter REG_COUNT = 8
)(
    input  wire               clk,
    input  wire               rstn,
    input  wire               shift_en,     // 1 bit shift per cycle when high
    input  wire [2:0]         rs1_addr,
    input  wire [2:0]         rs2_addr,
    output wire               rs1_bit,
    output wire               rs2_bit,
    input  wire [2:0]         rd_addr,
    input  wire               wr_bit,
    input  wire               wr_en         // write current bit to RD reg
);

endmodule