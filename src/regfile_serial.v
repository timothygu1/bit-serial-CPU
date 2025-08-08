// ============================================================================
// regfile_serial.v | Serial-access register file
// ============================================================================

`default_nettype none

module regfile_serial #(
    parameter REG_WIDTH = 8,
    parameter REG_COUNT = 8
)(
    input  wire               clk,
    input  wire               rstn,
    input  wire               reg_shift_en,         // 1 bit shift per cycle when high
    input  wire [11:0]        instr,
    input  wire [7:0]         regs_parallel_in,
    input  wire [2:0]         alu_op,
    output reg  [2:0]         bit_index,
    output wire [7:0]         regfile_bits,
    output wire               rs1_bit,
    output wire               rs2_bit,
    input  wire               reg_store_en          // parallel store from accumulator
);

    wire [2:0] rs1_addr  = instr[2:0];
    wire [2:0] rs2_addr  = instr[6:4];                               // only relevant for R-type
    wire [2:0] shift_imm = (instr[11:4] >= 7) ? 3'b111 : instr[6:4]; // only relevant for I-type

    /*    Register file    */
    reg [REG_WIDTH-1:0] regs [0:REG_COUNT-1];

    /* verilator lint_off UNUSED */
    wire unused_instr3 = instr[3];
    /* verilator lint_on UNUSED */

    integer i;

    always @(posedge clk) begin
        if (!rstn) begin
            bit_index <= 0;
            for (i = 0; i < REG_COUNT; i = i + 1)
            regs[i] <= 0;
        end else if (reg_shift_en) begin
            bit_index <= bit_index + 1;                         // increment bit index each cycle
        end else if (reg_store_en & rs1_addr != 3'b0) begin     // do not write to 0 register
            regs[rs1_addr] <= regs_parallel_in;
        end
    end

    /*
     * Compute shifted-bit helpers with bounds checking:
     *  - sl_bit: regs[rs1_addr][bit_index - shift_imm] if bit_index>=shift_imm, else 0
     *  - sr_bit: regs[rs1_addr][bit_index + shift_imm] if bit_index+shift_imm<REG_WIDTH, else 0
     * 
     * rs1_bit selects sl_bit for SLLI (alu_op==3'b101), sr_bit for SRLI (alu_op==3'b110), else direct bit
     */
    wire sl_bit = (bit_index >= shift_imm)
                ? regs[rs1_addr][bit_index - shift_imm]
                : 1'b0;
    wire sr_bit = ((bit_index + shift_imm) < REG_WIDTH)
                ? regs[rs1_addr][bit_index + shift_imm]
                : 1'b0;
    assign rs1_bit =
        (alu_op == 3'b101) ? sl_bit :   // SLLI
        (alu_op == 3'b110) ? sr_bit :   // SRLI
        regs[rs1_addr][bit_index];      // normal

    // rs2_bit: always regs[rs2_addr][bit_index].
    assign rs2_bit = regs[rs2_addr][bit_index];

    // regfile_bits: full contents of regs[rs1_addr].
    assign regfile_bits = regs[rs1_addr];

endmodule
