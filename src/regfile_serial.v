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

    reg [REG_WIDTH-1:0] regs [0:REG_COUNT-1];

    reg [$clog2(REG_WIDTH)-1:0] bit_index;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            bit_index <= 0;
        end else if (shift_en) begin
            bit_index <= bit_index + 1; // increment bit index each cycle
        end
    end

    assign rs1_bit = regs[rs1_addr][bit_index];
    assign rs2_bit = regs[rs2_addr][bit_index];

    always @(posedge clk) begin
        if (wr_en) begin
            regs[rd_addr][bit_index] <= wr_bit;
        end
    end

endmodule