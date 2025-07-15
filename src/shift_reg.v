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

    // We need to delay the input from the ALU for 1 cycle before starting to write.
    reg serial_in_d; // delay register
    reg shift_started;
    reg [$clog2(WIDTH)-1:0] bit_index;
    
    // next-state datapath
    wire [WIDTH-1:0] next_q =
        load          ? parallel_in : {serial_in, q[WIDTH-1:1]};       

     always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q <= {WIDTH{1'b0}};   // synchronous clear
            serial_in_d <= 1'b0;         // also reset delay register
            bit_index <= 0;
        end else if (en) begin
            serial_in_d <= serial_in; // delay input by one cycle for data alignment

            if (load) begin
            q <= parallel_in;
            bit_index <= 0;
            shift_started <= 0;
        end else begin
            if (shift_started) begin
                q[bit_index] <= serial_in_d;
                bit_index <= bit_index + 1;
            end else begin
                // Don't write yet — first cycle of serial_in_d
                shift_started <= 1;
            end
        end
    end
end

endmodule