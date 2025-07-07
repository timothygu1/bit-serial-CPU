// cpu_core.v - 

`default_nettype none

module cpu_core (
    input  wire        clk,
    input  wire        rstn,
    input  wire [3:0]  opcode,
    input  wire [11:0] instr,
    input  wire        btn_edge,
    output wire [7:0]  out
);
    // Wires between modules
    wire a_bit, b_bit, alu_result;
    wire [1:0] alu_op;
    wire carry_in, carry_out;

    wire shift_a, shift_b, shift_out;
    wire load_a, load_b, load_out;
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

    // Instantiate A register (shift_reg)
    wire [7:0] a_parallel;
    assign a_parallel = instr[7:0]; // rs1 or imm
    shift_reg #(8) reg_a (
        .clk(clk),
        .rstn(rstn),
        .en(shift_a || load_a),
        .load(load_a),
        .dir(1'b1), // always shift right
        .serial_in(1'b0), // don't care during shift
        .parallel_in(a_parallel),
        .q(), // unused
        .serial_out(a_bit)
    );

    // Instantiate B register (shift_reg)
    wire [7:0] b_parallel = {5'b0, instr[11:9]}; // rs2 in R-type (3 bits)
    shift_reg #(8) reg_b (
        .clk(clk),
        .rstn(rstn),
        .en(shift_b || load_b),
        .load(load_b),
        .dir(1'b1),
        .serial_in(1'b0),
        .parallel_in(b_parallel),
        .q(),
        .serial_out(b_bit)
    );

    // OUT register
    shift_reg #(8) reg_out (
        .clk(clk),
        .rstn(rstn),
        .en(shift_out || load_out),
        .load(load_out),
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
        .btn_edge(btn_edge),
        .bit_done(bit_done),
        .load_a(load_a),
        .load_b(load_b),
        .shift_a(shift_a),
        .shift_b(shift_b),
        .shift_out(shift_out),
        .alu_op(alu_op),
        .clr_counter(clr_counter),
        .en_counter(en_counter),
        .load_out(load_out),
        .carry_en(carry_en)
    );

endmodule
