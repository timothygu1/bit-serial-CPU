// counter.v - 

`default_nettype none

module counter (
    input  wire clk,
    input  wire rstn,
    input  wire en,       // increment enable
    input  wire clr,      // synchronous clear
    output wire done,     // asserted when count == 7
    output reg  [2:0] count  // 3-bit counter
);

    always @(posedge clk) begin
        if (!rstn)
            count <= 3'b000;
        else if (clr)
            count <= 3'b000;
        else if (en)
            count <= count + 1'b1;
    end

    assign done = (count == 3'b111);  // after 8 bits

endmodule
