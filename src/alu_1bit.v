// alu_1bit.v - 1-bit serial ALU

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
    wire inverted = ~rs2; // Inverted rs2 for subtraction

    always @(posedge clk) begin
        carry_in <= carry_out;
        if (!rst_n) begin
            carry_in <= 0;
            alu_result <= 0;
        end else if (alu_en) begin
            // process one bit this cycle
            if (alu_op == 3'b000) begin                         // ADD
                alu_result <= rs1 ^ rs2 ^ carry_in;
            end else if (alu_op == 3'b001) begin                // SUB
                if (alu_start) alu_result <= rs1 ^ inverted ^ 1;
                else alu_result <= rs1 ^ inverted ^ carry_in;
            end else if (alu_op == 3'b010) begin                // XOR
                alu_result <= rs1 ^ rs2;
            end else if (alu_op == 3'b011) begin                // AND
                alu_result <= rs1 & rs2;
            end else if (alu_op == 3'b100) begin                // OR
                alu_result <= rs1 | rs2;
            end else if (alu_op == 3'b101 || alu_op == 3'b110) begin // SLLI, SRLI
                alu_result <= rs1;
            end else begin
                alu_result <= 1'b0;
            end
        end
    end

   assign carry_out = (alu_start && (alu_op == 3'b001)) ? 1'b1 :
                    (alu_en && (alu_op == 3'b001)) ? (rs1 & inverted) | (rs1 & carry_in) | (inverted & carry_in) :
                    (alu_en && (alu_op == 3'b000)) ? (rs1 & rs2) | (rs1 & carry_in) | (rs2 & carry_in) :
                    1'b0;

endmodule
