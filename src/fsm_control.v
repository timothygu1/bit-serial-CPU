// fsm_control.v - 

`default_nettype none

module fsm_control (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [3:0]  opcode,     // from top.v
    input  wire        inst_done,  // full instruction loaded from top.v
    input  wire        btn_edge,   // one-pulse from top.v
    input  wire        bit_done,   // from counter.v

    output reg         reg_shift_en,
    output reg         reg_write_en,
    output reg         acc_write_en,
    output reg         acc_shift_en,
    output reg         imm_shift_en,
    output reg  [1:0]  alu_op,
    output reg         clr_counter,
    output reg         en_counter,
    output reg         carry_en
);

    // State encoding
    parameter S_IDLE      = 3'd0;
    parameter S_EXECUTE   = 3'd1;
    parameter S_ACC_PREP = 3'd2;
    parameter S_WRITE_ACC = 3'd3;

    reg [2:0] state, next_state;

    // LINT: unused for now 
    // wire is_rtype = opcode[3]; // 1 = R-type, 0 = I-type

    //wire [7:0] imm = is_rtype ? 8'b00000000 : instr[11:4]; // only relevant for I-type

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
    always @(posedge clk) begin
        if (!rst_n)
            state <= S_IDLE;
        else
            state <= next_state;
    end

    // Next state logic
    always @(*) begin
        next_state = state;
        case (state)
            default:
                next_state = S_IDLE;
            S_IDLE:
                if (btn_edge && inst_done)
                    next_state = S_EXECUTE;

            S_EXECUTE:
                    next_state = S_WRITE_ACC;
                
            // S_ACC_PREP:
            //         next_state = S_WRITE_ACC;

            S_WRITE_ACC:
                if (bit_done)
                    next_state = S_IDLE;
        endcase
    end

    // Outputs
    always @(*) begin
        // Default: deassert everything
        reg_shift_en    = 0;
        reg_write_en    = 0;
        acc_write_en    = 0;
        acc_shift_en    = 0;
        imm_shift_en    = 0;
        alu_op          = 2'b00;
        clr_counter     = 0;
        en_counter      = 0;
        carry_en        = 0;
        
        case (state)
            S_IDLE: begin
                clr_counter = 1;
            end

            S_EXECUTE: begin
                reg_shift_en = 1;
                alu_op       = decode_alu_op(opcode);
                en_counter   = 1;
                carry_en     = 1;
                acc_write_en = 1;
            end

            S_ACC_PREP: begin
                reg_shift_en = 1;
                alu_op       = decode_alu_op(opcode);
                en_counter   = 1;
                carry_en     = 1;
                acc_write_en = 1;
            end

            S_WRITE_ACC: begin
                reg_shift_en = 1;
                alu_op       = decode_alu_op(opcode);
                en_counter   = 1;
                carry_en     = 1;
                acc_write_en = 1;
            end
        endcase
    end

    wire _unused = &{reg_write_en, acc_shift_en, acc_write_en, imm_shift_en};

endmodule