// ============================================================================
// fsm_control.v   | Finite State Machine control logic
// ============================================================================

`default_nettype none

module fsm_control (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [3:0]  opcode,          // from top.v
    input  wire        inst_done,       // full instruction loaded from top.v
    input  wire        btn_edge,        // one-pulse from top.v
    input  wire        bit_done,        // from shift_reg.v
    output reg         alu_start,
    output reg         reg_shift_en,
    output reg         reg_store_en,
    output reg         acc_write_en,
    output reg         acc_load_en,
    output reg  [2:0]  alu_op,
    output reg         alu_en,
    output reg         out_en
);

    // State encoding
    parameter S_IDLE      = 3'd0;
    parameter S_DECODE    = 3'd1;
    parameter S_SHIFT_REGS   = 3'd2;
    parameter S_WRITE_ACC = 3'd3;
    parameter S_OUTPUT = 3'd4;

    reg [2:0] state, next_state;

    // ALU opcode decoder
    function [2:0] decode_alu_op(input [3:0] opc);
        case (opc)
            4'b0000, 4'b1000: decode_alu_op = 3'b000;   // ADD, ADDI
            4'b0001, 4'b1001: decode_alu_op = 3'b001;   // SUB, SUBI (b must be inverted in datapath or FSM)
            4'b0110, 4'b1100: decode_alu_op = 3'b010;   // XOR, XORI
            4'b0101, 4'b1011: decode_alu_op = 3'b011;   // AND, ANDI
            4'b0100, 4'b1010: decode_alu_op = 3'b100;   // OR,  ORI
            4'b0010:          decode_alu_op = 3'b101;   // SLLI
            4'b0011:          decode_alu_op = 3'b110;   // SRLI
            default:          decode_alu_op = 3'b000;
        endcase
    endfunction

    // FSM state register
    always @(posedge clk) begin
        if (!rst_n)
            state <= S_IDLE;
        else begin
            if (state == S_OUTPUT || state == S_DECODE) begin
                out_en <= 1;
            end
            else begin
                out_en <= 0;
            end
            state <= next_state;
        end
    end

    /*
     * FSM next-state logic:
     * - Default:       transitions to IDLE.
     * - In IDLE:       on button edge & instruction done -> DECODE.
     * - In DECODE:     if load/store (opcode 0111,1101,1110) -> IDLE; else -> SHIFT_REGS.
     * - In SHIFT_REGS: on bit_done -> OUTPUT.
     * - In WRITE_ACC:  unconditionally -> OUTPUT.
     * - In OUTPUT:     transitions to IDLE.
     */
    always @(*) begin
        next_state = state;
        case (state)
            default:
                next_state = S_IDLE;
            S_IDLE:
                if (btn_edge && inst_done)
                    next_state = S_DECODE;

            S_DECODE:
                if (opcode == 4'b0111 || opcode == 4'b1101 || opcode == 4'b1110) begin // loadi, load, store
                    next_state = S_IDLE;
                end
                else next_state = S_SHIFT_REGS;

            S_SHIFT_REGS:
                if (bit_done)
                    next_state = S_OUTPUT;

            S_WRITE_ACC:
                    next_state = S_OUTPUT;

            S_OUTPUT:
                    next_state = S_IDLE;
        endcase
    end

    // precompute decode flags and op
    wire        is_load    = (opcode == 4'b0111) || (opcode == 4'b1101);
    wire        is_store   = (opcode == 4'b1110);
    wire        do_shift   = (state == S_SHIFT_REGS);
    wire        do_write   = (state == S_WRITE_ACC) || (state == S_OUTPUT);
    wire        do_calc    = (state == S_DECODE && !is_load && !is_store)
                        || do_shift
                        || do_write;

    wire [2:0]  alu_decoded = decode_alu_op(opcode);

    // continuous assignments
    always @(*) begin
        alu_op       = alu_decoded;
        alu_en       = do_calc;
        alu_start    = (state == S_DECODE && !is_load && !is_store);
        acc_load_en  = (state == S_DECODE && is_load);
        reg_store_en = (state == S_DECODE && is_store);
        reg_shift_en = (state == S_DECODE && !is_load && !is_store) || do_shift;
        acc_write_en = do_shift || do_write;
    end

endmodule
