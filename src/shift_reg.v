// shift_reg.v - shift register with optional parallel load

`default_nettype none

module shift_reg
#(parameter WIDTH = 8)
(
    input  wire                  clk,
    input  wire                  rst_n,        // active-low synchronous reset
    input  wire                  en,          // 1 -> perform load/shift
    input  wire                  load,        // 1 -> parallel load, 0 -> shift
    input  wire                  serial_in,   // bit entering during a shift
    input  wire  [WIDTH-1:0]     parallel_in, // data for parallel load
    output reg   [WIDTH-1:0]     q           // register contents
);

    reg [$clog2(WIDTH)-1:0] bit_index;
    
    // next-state datapath
    wire [WIDTH-1:0] next_q =
        load          ? parallel_in : {serial_in, q[WIDTH-1:1]};       

     always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q <= {WIDTH{1'b0}};   // synchronous clear
            bit_index <= 0;
        end else if (en) begin
            if (load) begin
                q[WIDTH-1:0] <= parallel_in;
                bit_index <= 0;
            end else begin
                q[bit_index] <= serial_in;
                bit_index <= bit_index + 1; // increment bit index each cycle
            end
        end
    end

endmodule