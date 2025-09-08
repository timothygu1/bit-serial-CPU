// ============================================================================
// accumulator.v   | shift register with optional parallel load
// ============================================================================

`default_nettype none

module accumulator
#(parameter WIDTH = 8)
(
    input  wire                      clk,
    input  wire                      rst_n,           // active-low synchronous reset
    input  wire                      acc_write_en,    // 1 -> perform load/shift
    input  wire                      acc_load_en,     // 1 -> parallel load, 0 -> shift
    input  wire  [WIDTH-1:0]         acc_parallel_in,
    input  wire                      alu_result,      // bit entering during a shift
    input  wire  [$clog2(WIDTH)-1:0] bit_index_d,
    output reg   [WIDTH-1:0]         acc_bits,        // register contents
    output reg                       done
);


    always @(posedge clk) begin
        if (!rst_n) begin
            acc_bits <= {WIDTH{1'b0}};     // synchronous clear
        end else if (acc_load_en) begin
            acc_bits <= acc_parallel_in;
        end else if (acc_write_en) begin
            acc_bits[bit_index_d] <= alu_result;
        end else begin
        end
    end


    // Combinational logic
    always @(*) begin
        if (bit_index_d == $clog2(WIDTH)'(WIDTH - 2)) begin
            done = 1;
        end
        else begin
            done = 0;
        end
    end

endmodule
 