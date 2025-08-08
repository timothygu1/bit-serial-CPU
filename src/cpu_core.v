// ============================================================================
// cpu_core.v      | Bit-serial CPU core
// ============================================================================

`default_nettype none

module cpu_core (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [3:0]  opcode,
    input  wire [11:0] instr,
    input  wire        inst_done,
    input  wire        btn_edge,
    output reg  [7:0]  out_result

);

    /*     CPU Core output     */
    wire [7:0] acc_bits;
    wire out_en;

    wire [2:0] bit_index;                                               // Tracks regFile bit index
    reg [2:0] bit_index_d;                                              // Delayed bit_index passed to accumulator

    /*      ALU Operands & Signals            */
    wire alu_bit1, alu_bit2, rs2_bit, alu_result;
    wire [2:0] alu_op;
    wire alu_start;
    wire alu_en;

    /*      Regfile & Accumulator Control Signals     */
    wire reg_shift_en, acc_write_en;
    wire reg_store_en, acc_load_en;
    wire bit_done;

    wire [7:0] acc_parallel_in;
    wire [7:0] regfile_bits;

    /*      R-type vs I-type Multiplexers          */

    // Accumulator parallel 2-1 mux
    assign acc_parallel_in = acc_load_en ? (opcode[3] ? regfile_bits : instr[11:4]) : 8'b0;
    // ALU 2-1 mux
    assign alu_bit2 = (opcode[3]) ? rs2_bit : (instr[bit_index + 4]);

    // Generating delayed bit index
    always @(posedge clk) begin
        if (!rst_n) begin
            bit_index_d <= 0;
            out_result <= 0;
        end else begin
            if (out_en) begin
                out_result <= acc_bits;
            end
            bit_index_d <= bit_index;
        end
    end

    /*      Module connections begin here      */

    // Addressable register file
    regfile_serial regfile (
        .clk(clk),
        .rstn(rst_n),
        .reg_shift_en(reg_shift_en),
        .instr(instr),
        .alu_op(alu_op),
        .rs1_bit(alu_bit1),
        .rs2_bit(rs2_bit),
        .regs_parallel_in(acc_bits),
        .bit_index(bit_index),
        .regfile_bits(regfile_bits),
        .reg_store_en(reg_store_en)
    );

    // Accumulator register
    accumulator #(8) acc (
        .clk(clk),
        .rst_n(rst_n),
        .acc_load_en(acc_load_en),
        .acc_parallel_in(acc_parallel_in),
        .acc_write_en(acc_write_en),
        .alu_result(alu_result),
        .acc_bits(acc_bits),
        .bit_index_d(bit_index_d),
        .done(bit_done)
    );

    // Bit-serial ALU
    alu_1bit alu (
        .clk(clk),
        .rst_n(rst_n),
        .rs1(alu_bit1),
        .rs2(alu_bit2),
        .alu_start(alu_start),
        .alu_op(alu_op),
        .alu_en(alu_en),
        .alu_result(alu_result)
    );

    // Control FSM
    fsm_control ctrl (
        .clk(clk),
        .rst_n(rst_n),
        .opcode(opcode),
        .inst_done(inst_done),
        .btn_edge(btn_edge),
        .bit_done(bit_done),
        .alu_op(alu_op),
        .alu_start(alu_start),
        .acc_load_en(acc_load_en),
        .acc_write_en(acc_write_en),
        .reg_shift_en(reg_shift_en),
        .reg_store_en(reg_store_en),
        .alu_en(alu_en),
        .out_en(out_en)
    );

endmodule
