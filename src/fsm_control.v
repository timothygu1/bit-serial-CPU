// fsm_control.v - 

`default_nettype none

module fsm_control (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [3:0]  opcode,     // from top.v
    input  wire        inst_done,  // full instruction loaded from top.v
    input  wire        btn_edge,   // one-pulse from top.v
    input  wire        bit_done,   // from shift_reg.v
    output reg         alu_start,
    output reg         reg_shift_en,
    output reg         reg_store_en,
    output reg         acc_write_en,
    output reg         acc_load_en,
    output reg         imm_shift_en,
    output reg  [2:0]  alu_op,
    output reg         carry_en
);

    // State encoding
    parameter S_IDLE      = 3'd0;
    parameter S_DECODE    = 3'd1;
    parameter S_SHIFT_REGS   = 3'd2;
    parameter S_WRITE_ACC = 3'd3;
    parameter S_LOAD = 3'd4;

    reg [2:0] state, next_state;

    // LINT: unused for now 
    // wire is_rtype = opcode[3]; // 1 = R-type, 0 = I-type

    //wire [7:0] imm = is_rtype ? 8'b00000000 : instr[11:4]; // only relevant for I-type

    // ALU opcode decoder
    function [2:0] decode_alu_op(input [3:0] opc);
        case (opc)
            4'b0000, 4'b1000: decode_alu_op = 3'b000; // ADD, ADDI
            4'b0001, 4'b1001: decode_alu_op = 3'b001; // SUB, SUBI (b must be inverted in datapath or FSM)
            4'b0110, 4'b1100: decode_alu_op = 3'b010; // XOR, XORI
            4'b0101, 4'b1011: decode_alu_op = 3'b011; // AND, ANDI
            4'b0100, 4'b1010: decode_alu_op = 3'b100; // OR,  ORI
            4'b0010:          decode_alu_op = 3'b101; // SLLI
            4'b0011:          decode_alu_op = 3'b110; // SRLI
            default:          decode_alu_op = 3'b000;
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
                    next_state = S_DECODE;

            S_DECODE:
                if (opcode == 4'b0111 || opcode == 4'b1101 || opcode == 4'b1110) // loadi, load, store
                    next_state = S_IDLE;  
                else next_state = S_SHIFT_REGS;

            S_SHIFT_REGS:
                if (bit_done)
                    next_state = S_WRITE_ACC;
                

            S_WRITE_ACC:
                    next_state = S_IDLE;

            S_LOAD:
                    next_state = S_IDLE;
        endcase
    end

    // Outputs
    always @(*) begin
        // Default: deassert everything
        reg_shift_en    = 0;
        reg_store_en    = 0;
        acc_write_en    = 0;
        acc_load_en     = 0;
        imm_shift_en    = 0;
        alu_op          = 3'b00;
        carry_en        = 0;
        alu_start       = 0;
        
        case (state)
            S_IDLE: begin
            end

            S_DECODE: begin
                alu_op       = decode_alu_op(opcode);
                if (opcode == 4'b0111 || opcode == 4'b1101) begin // loadi, load
                    acc_load_en = 1;
                end else if (opcode == 4'b1110) begin  // store
                    reg_store_en = 1;
                end else begin
                    alu_start    = 1;
                    carry_en = 1;
                    reg_shift_en = 1;
                end
            end

            S_SHIFT_REGS: begin
                reg_shift_en = 1;
                alu_op       = decode_alu_op(opcode);
                carry_en     = 1;
                acc_write_en = 1;
            end


            S_WRITE_ACC: begin
                alu_op       = decode_alu_op(opcode);
                carry_en     = 1;
                acc_write_en = 1;
            end

        endcase
    end

    wire _unused = &{imm_shift_en};

endmodule