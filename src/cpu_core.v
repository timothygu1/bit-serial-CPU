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
    wire a_bit, b_bit, alu_result;
    wire [1:0] alu_op;
    wire carry_in, carry_out;

    wire reg_shift_en, acc_shift_en;
    wire [2:0] reg_addr_sel;
    wire reg_out_bit;
    wire reg_write_en, acc_write_en;
    wire en_counter, clr_counter;
    wire bit_done;
    wire carry_en;

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
        .serial_out()
    );

    // ALU
    alu_1bit alu (
        .a(a_bit),
        .b(b_bit),
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
        .clr_counter(clr_counter),
        .en_counter(en_counter),
        .carry_en(carry_en)
    );

endmodule
