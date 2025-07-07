// alu_1bit.v - 

`default_nettype none

module alu_1bit (
    input  wire a,
    input  wire b,
    input  wire carry_in,
    input  wire [1:0] alu_op,   // 2-bit op select
    output wire result,
    output wire carry_out
);

    wire add_result = a ^ b ^ carry_in;
    wire add_cout   = (a & b) | (a & carry_in) | (b & carry_in);

    wire and_result = a & b;
    wire or_result  = a | b;
    wire xor_result = a ^ b;

    assign result = (alu_op == 2'b00) ? add_result :
                    (alu_op == 2'b01) ? xor_result :
                    (alu_op == 2'b10) ? and_result :
                    (alu_op == 2'b11) ? or_result  :
                    1'b0;

    assign carry_out = (alu_op == 2'b00) ? add_cout : 1'b0;

endmodule
