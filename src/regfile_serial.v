// regfile_serial.v

`default_nettype none

module regfile_serial #(
    parameter REG_WIDTH = 8,
    parameter REG_COUNT = 8
)(
    input  wire               clk,
    input  wire               rstn,
    input  wire               reg_shift_en,     // 1 bit shift per cycle when high
    // LINT: temporary disable (to be implemented later)
    /* verilator lint_off UNUSED */
    input  wire [11:0]        instr,
    /* verilator lint_on UNUSED */
    input  wire               is_rtype,
    output wire               rs1_bit,
    output wire               rs2_bit,
    input  wire               wr_bit,
    input  wire               wr_en         // write current bit to RD reg
);

    wire [2:0] rs1_addr = instr[2:0];
    wire [2:0] rs2_addr = is_rtype ? instr[6:4] : 3'b000; // only relevant for R-type

    reg [REG_WIDTH-1:0] regs [0:REG_COUNT-1];

    reg [$clog2(REG_WIDTH)-1:0] bit_index;

    integer i;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            bit_index <= 0;
            for (i = 0; i < REG_COUNT; i = i + 1)
            regs[i] <= 0;
        end else if (reg_shift_en) begin
            bit_index <= bit_index + 1; // increment bit index each cycle
        end else if (wr_en) begin
            // todo: add parallel load
            regs[rs1_addr][bit_index] <= wr_bit;
            bit_index <= bit_index + 1;
        end
    end

    assign rs1_bit = regs[rs1_addr][bit_index];
    assign rs2_bit = regs[rs2_addr][bit_index];

    // always @(posedge clk) begin
    //     if (wr_en) begin
    //         regs[rs1_addr][bit_index] <= wr_bit;
    //     end
    // end

   // wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule