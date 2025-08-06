// ============================================================================
// alu_1bit.v      | 1-bit serial ALU
// ============================================================================

`default_nettype none

module alu_1bit (
    input  wire clk,
    input  wire rst_n,
    input  wire rs1,
    input  wire rs2,
    input  wire [2:0] alu_op,   // 3-bit op select
    input  wire alu_en,
    input  wire alu_start,
    output reg alu_result
);

    wire carry_out;
    reg carry_in;
    wire inverted = ~rs2;       // Inverted rs2 for subtraction

    always @(posedge clk) begin
        carry_in   <= carry_out;
        if (!rst_n) begin
            carry_in   <= 1'b0;
            alu_result <= 1'b0;
        end else if (alu_en) begin
            // process one bit this cycle
            case (alu_op)
                3'b000: alu_result <= rs1 ^ rs2 ^ carry_in;        // ADD
                3'b001:                                            // SUB
                    if (alu_start)
                        alu_result <= rs1 ^ inverted ^ 1'b1;
                    else
                        alu_result <= rs1 ^ inverted ^ carry_in;
                3'b010: alu_result <= rs1 ^ rs2;                   // XOR
                3'b011: alu_result <= rs1 & rs2;                   // AND
                3'b100: alu_result <= rs1 | rs2;                   // OR
                3'b101,
                3'b110: alu_result <= rs1;                         // SLLI, SRLI
                default: alu_result <= 1'b0;
            endcase
        end
    end

    /*
    * carry_out logic:
    * - On SUB start (alu_op==3'b001 & alu_start): preload carry=1.
    * - When alu_en: compute full-adder carry for SUB (rs1, ~rs2, carry_in) or ADD (rs1, rs2, carry_in).
    * - Otherwise default carry_out=0.
    */
    assign carry_out = (alu_start && (alu_op == 3'b001)) ? 1'b1 :
                       (alu_en && (alu_op == 3'b001)) ? (rs1 & inverted) | (rs1 & carry_in) | (inverted & carry_in) :
                       (alu_en && (alu_op == 3'b000)) ? (rs1 & rs2) | (rs1 & carry_in) | (rs2 & carry_in) :
                       1'b0;

endmodule
