// cpu_core.v - 

`default_nettype none

module cpu_core (
    input  wire        clk,
    input  wire        rstn,
    input  wire [3:0]  opcode,
    input  wire [11:0] instr,
    input  wire        inst_done,
    input  wire        btn_edge,
    output wire [7:0]  out
);

    // Wires between modules
    wire rs1_bit, rs2_bit, alu_result;
    wire rs1_addr, rs2_addr;
    wire [1:0] alu_op;
    wire carry_in, carry_out;

    wire reg_shift_en, acc_shift_en;
    wire [2:0] reg_addr_sel;
    wire reg_write_en, acc_write_en;
    wire en_counter, clr_counter;
    wire bit_done;
    wire carry_en;
    wire acc_out_bit;

    // Carry register
    reg carry;
    always @(posedge clk)
        if (!rstn)
            carry <= 0;
        else if (carry_en)
            carry <= 0;
        else
            carry <= carry_out;

    // TODO: REGFILE
    regfile_serial regfile (
        .clk(clk),
        .rstn(rstn),
        .reg_shift_en(reg_shift_en),
        .instr(instr),
        .is_rtype(opcode[3]),
        .rs1_bit(rs1_bit),
        .rs2_bit(rs2_bit),
        .wr_bit(acc_out_bit),
        .wr_en(reg_write_en)
    );

    // Accumulator register
    shift_reg #(8) acc (
        .clk(clk),
        .rstn(rstn),
        .en(acc_shift_en || acc_write_en),
        .load(acc_write_en),
        .dir(1'b1),
        .serial_in(alu_result),
        .parallel_in(8'b0),
        .q(out),
        .serial_out(acc_out_bit)
    );

    // ALU
    alu_1bit alu (
        .rs1(rs1_bit),
        .rs2(rs2_bit),
        .carry_in(carry),
        .alu_op(alu_op),
        .result(alu_result),
        .carry_out(carry_out)
    );

    // Counter
    counter exec_counter (
        .clk(clk),
        .rstn(rstn),
        .en(en_counter),
        .clr(clr_counter),
        .done(bit_done),
        .count() // optional
    );

    // Control FSM
    fsm_control ctrl (
        .clk(clk),
        .rstn(rstn),
        .opcode(opcode),
        .instr(instr),
        .inst_done(inst_done),
        .btn_edge(btn_edge),
        .bit_done(bit_done),
        .alu_op(alu_op),
        .reg_shift_en(reg_shift_en),
        .clr_counter(clr_counter),
        .en_counter(en_counter),
        .carry_en(carry_en)
    );

endmodule
