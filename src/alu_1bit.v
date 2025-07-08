// alu_1bit.v - 

`default_nettype none

module alu_1bit (
    input  wire rs1,
    input  wire rs2,
    input  wire carry_in,
    input  wire [1:0] alu_op,   // 2-bit op select
    output wire result,
    output wire carry_out
);

    wire add_result = rs1 ^ rs2 ^ carry_in;
    wire add_cout   = (rs1 & rs2) | (rs1 & carry_in) | (rs2 & carry_in);

    wire and_result = rs1 & rs2;
    wire or_result  = rs1 | rs2;
    wire xor_result = rs1 ^ rs2;

    assign result = (alu_op == 2'b00) ? add_result :
                    (alu_op == 2'b01) ? xor_result :
                    (alu_op == 2'b10) ? and_result :
                    (alu_op == 2'b11) ? or_result  :
                    1'b0;

    assign carry_out = (alu_op == 2'b00) ? add_cout : 1'b0;

endmodule
