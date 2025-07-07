// shift_reg.v - bidirectional shift register with optional parallel load

`default_nettype none

module bidir_shift_reg
#(parameter WIDTH = 8)
(
    input  wire                  clk,
    input  wire                  rstn,        // active-low synchronous reset
    input  wire                  en,          // 1 -> perform load/shift
    input  wire                  load,        // 1 -> parallel load, 0 -> shift
    input  wire                  dir,         // 0 -> shift left, 1 -> shift right
    input  wire                  serial_in,   // bit entering during a shift
    input  wire  [WIDTH-1:0]     parallel_in, // data for parallel load
    output reg   [WIDTH-1:0]     q,           // register contents
    output wire                  serial_out   // bit exiting during a shift
);

    // next-state datapath
    wire [WIDTH-1:0] next_q =
        load          ? parallel_in                    : // parallel load
        (dir == 1'b0) ? {q[WIDTH-2:0], serial_in}      : // shift left
                        {serial_in, q[WIDTH-1:1]};       // shift right

    // sequential part
    always @(posedge clk)
        if (!rstn)
            q <= {WIDTH{1'b0}};   // synchronous clear
        else if (en)
            q <= next_q;          // load or shift

    // bit shifted out on this cycle
    assign serial_out = dir ? q[0] : q[WIDTH-1];

endmodule