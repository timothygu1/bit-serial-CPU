// regfile_serial.v

`default_nettype none

module regfile_serial #(
    parameter REG_WIDTH = 8,
    parameter REG_COUNT = 8
)(
    input  wire               clk,
    input  wire               rstn,
    input  wire               reg_shift_en,     // 1 bit shift per cycle when high
    input  wire [11:0]        instr,
    input  wire [7:0]         regs_parallel_in,
    input  wire [2:0]         alu_op,
    output reg  [2:0]         bit_index,
    output wire [7:0]         regfile_bits,
    output wire               rs1_bit,
    output wire               rs2_bit,
    input  wire               reg_store_en      // parallel store from accumulator
);

    wire [2:0] rs1_addr  = instr[2:0];
    wire [2:0] rs2_addr  = instr[6:4];  // only relevant for R-type
    wire [2:0] shift_imm = (instr[11:4] >= 7) ? 3'b111 : instr[6:4]; // only relevant for I-type

    reg [REG_WIDTH-1:0] regs [0:REG_COUNT-1];

    integer i;

    always @(posedge clk) begin
        if (!rstn) begin
            bit_index <= 0;
            for (i = 0; i < REG_COUNT; i = i + 1)
            regs[i] <= 0;
        end else if (reg_shift_en) begin
            bit_index <= bit_index + 1; // increment bit index each cycle
        end else if (reg_store_en & rs1_addr != 3'b0) begin // do not write to 0 register
            // todo: add parallel store from accumulator
            regs[rs1_addr] <= regs_parallel_in;
        end
    end
    
    assign rs1_bit =
    (alu_op == 3'b101) ? (
        (bit_index >= shift_imm) ? regs[rs1_addr][bit_index - shift_imm] : 1'b0
    ) :
    (alu_op == 3'b110) ? (
        ((bit_index + shift_imm) < REG_WIDTH) ? regs[rs1_addr][bit_index + shift_imm] : 1'b0
    ) :
    regs[rs1_addr][bit_index];

    assign rs2_bit = regs[rs2_addr][bit_index];

    assign regfile_bits = regs[rs1_addr];

   // wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule