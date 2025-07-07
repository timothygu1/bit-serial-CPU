// fsm_control.v - 

`default_nettype none

module fsm_control (
    input  wire        clk,
    input  wire        rstn,
    input  wire [3:0]  opcode,     // from top.v
    input  wire [11:0] instr,      // bits 15:4
    input  wire        btn_edge,   // one-pulse from top.v
    input  wire        bit_done,   // from counter.v

    output reg         load_a,
    output reg         load_b,
    output reg         shift_a,
    output reg         shift_b,
    output reg         shift_out,
    output reg  [1:0]  alu_op,
    output reg         clr_counter,
    output reg         en_counter,
    output reg         load_out,
    output reg         carry_en
);

    // State encoding
    parameter S_IDLE      = 3'd0;
    parameter S_LOAD_A    = 3'd1;
    parameter S_LOAD_B    = 3'd2;
    parameter S_EXECUTE   = 3'd3;
    parameter S_WRITE_OUT = 3'd4;

    reg [2:0] state, next_state;

    wire is_rtype = opcode[3]; // 1 = R-type, 0 = I-type

    // ALU opcode decoder
    function [1:0] decode_alu_op(input [3:0] opc);
        case (opc)
            4'b0000, 4'b1000: decode_alu_op = 2'b00; // ADD, ADDI
            4'b0001, 4'b1001: decode_alu_op = 2'b00; // SUB, SUBI (b must be inverted in datapath or FSM)
            4'b0110, 4'b1100: decode_alu_op = 2'b01; // XOR, XORI
            4'b0101, 4'b1011: decode_alu_op = 2'b10; // AND, ANDI
            4'b0100, 4'b1010: decode_alu_op = 2'b11; // OR,  ORI
            default:          decode_alu_op = 2'b00;
        endcase
    endfunction

    // FSM state register
    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            state <= S_IDLE;
        else
            state <= next_state;
    end

    // Next state logic
    always @(*) begin
        next_state = state;
        case (state)
            S_IDLE:
                if (btn_edge)
                    next_state = S_LOAD_A;

            S_LOAD_A:
                next_state = is_rtype ? S_LOAD_B : S_EXECUTE;

            S_LOAD_B:
                next_state = S_EXECUTE;

            S_EXECUTE:
                if (bit_done)
                    next_state = S_WRITE_OUT;

            S_WRITE_OUT:
                if (bit_done)
                    next_state = S_IDLE;
        endcase
    end

    // Outputs
    always @(*) begin
        // Default: deassert everything
        load_a      = 0;
        load_b      = 0;
        shift_a     = 0;
        shift_b     = 0;
        shift_out   = 0;
        load_out    = 0;
    end
endmodule