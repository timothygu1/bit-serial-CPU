module top_alu_fpga (
    input [7:0] sw,          // Switches 0-7 for A[7:0]
    input [7:0] swb,         // Switches 8-15 for B[7:0] (assuming continuous numbering)
    input btnC, btnU, btnD,  // Operation selection buttons
    output [7:0] led,        // LEDs 0-7 for result[7:0]
    output led_zero          // Additional LED for Zero flag
);
    // Note: Removed 10-bit extension since we're working with 8-bit ALU
    
    // Operation selection with buttons (3-bit encoding)
    wire [2:0] ALU_Sel = {btnC, btnU, btnD};
    
    // ALU connection
    wire [7:0] ALU_Result;  // 8-bit result
    wire Zero;              // Zero flag

    ALU alu_inst (
        .A(sw),      // Directly use switches 0-7 for A
        .B(swb),     // Directly use switches 8-15 for B
        .ALU_Sel(ALU_Sel),
        .ALU_Out(ALU_Result),
        .Zero(Zero)
    );

    // Output assignments
    assign led = ALU_Result;  // Show full 8-bit result on LEDs
    assign led_zero = Zero;   // Zero flag indicator
endmodule
