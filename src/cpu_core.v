// cpu_core.v - 

`default_nettype none

module cpu_core (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [3:0]  opcode,
    input  wire [11:0] instr,
    input  wire        inst_done,
    input  wire        btn_edge,
    output wire [7:0]  acc_bits
);

    // Wires between modules
    wire rs1_bit, rs2_bit, alu_result;
    wire [2:0] alu_op;

    wire alu_start;
    wire reg_shift_en, acc_write_en;
    wire imm_shift_en;
    wire reg_store_en, acc_load_en;
    wire en_counter, clr_counter;
    wire bit_done;
    wire carry_en;

    wire [7:0] acc_parallel_in;
    wire [7:0] regfile_bits;

    assign acc_parallel_in = acc_load_en ? (opcode[3] ? regfile_bits : instr[11:4]) // load from regfile if R-type, otherwise use imm
                             : 8'b0; 

    wire [2:0] count; // unused

    // TODO: REGFILE
    regfile_serial regfile (
        .clk(clk),
        .rstn(rst_n),
        .reg_shift_en(reg_shift_en),
        .instr(instr),
        .is_rtype(opcode[3]),
        .rs1_bit(rs1_bit),
        .rs2_bit(rs2_bit),
        .acc_bits(acc_bits),
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
        .done(bit_done)
    );

    // ALU
    alu_1bit alu (
        .clk(clk),
        .rst_n(rst_n),
        .rs1(rs1_bit),
        .rs2(rs2_bit),
        .alu_start(alu_start),
        .alu_op(alu_op),
        .alu_enable(carry_en),
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
        .imm_shift_en(imm_shift_en),
        .carry_en(carry_en)
    );

endmodule
