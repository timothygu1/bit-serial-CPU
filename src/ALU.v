// ALU with 8-bit Prefix Adder
module ALU (
    input [7:0] A, B,         // 8-bit operands
    input [2:0] ALU_Sel,      // Operation selector
    output reg [7:0] ALU_Out, // 8-bit result
    output Zero               // Zero flag
);
    // Prefix adder connection
    wire [7:0] sum;
    wire cout;
    PrefixAdder8 prefix_adder (
        .A(A),
        .B(B),
        .Sum(sum),
        .Cout(cout)
    );

    // Subtraction is implemented as A + (~B) + 1
    wire [7:0] sub_result;
    wire sub_cout;
    PrefixAdder8 subtractor (
        .A(A),
        .B(~B),
        .Sum(sub_result),
        .Cout(sub_cout)
    );

    // Zero flag
    assign Zero = (ALU_Out == 8'b0);

    // Operation selection
    always @(*) begin
        case(ALU_Sel)
            3'b000: ALU_Out = sum;               // Addition
            3'b001: ALU_Out = sub_result;        // Subtraction
            3'b010: ALU_Out = A & B;             // AND
            3'b011: ALU_Out = A | B;             // OR
            3'b100: ALU_Out = A ^ B;             // XOR
            3'b101: ALU_Out = A << 1;            // Shift left
            3'b110: ALU_Out = A >> 1;            // Shift right
            3'b111: ALU_Out = (A < B) ? 1 : 0;   // Comparison
            default: ALU_Out = 8'b0;
        endcase
    end
endmodule
