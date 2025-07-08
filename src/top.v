/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

// `include "shreg.v"

`default_nettype none

module tt_um_cpu_top (
    input  wire [7:0] ui_in,    // Inputs for instruction data (through DIP switches)
    output wire [7:0] uo_out,   // Outputs to drive LEDs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // All output pins must be assigned. If not used, assign to 0.
    assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
    assign uio_out = 0;
    assign uio_oe  = 0;

    reg [3:0] opcode;
    reg [11:0] instr;
    reg inst_done;

    // parallel load instructions into instr reg

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin // Reset
            opcode      <= 4'b0;
            instr       <= 12'b0;
            inst_done   <= 0;
        end
        else if (btn_edge) begin // Load if PB is pressed
            if (!inst_done) begin
                opcode       <= ui_in[3:0];
                instr[3:0]   <= ui_in[7:4];
                inst_done    <= 1'b1;
            end else begin
                instr[11:4]  <= ui_in;
                inst_done    <= 1'b0;
            end
        end
    end

    // Button edge-detector and synchronizer 

    reg btn_sync0, btn_sync1, btn_prev;
    wire btn_level = uio_in[0]; // external push button
    wire btn_edge = btn_sync1 & ~btn_prev; // detect rising edge

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            btn_sync0       <= 1'b0;
            btn_sync1       <= 1'b0;
            btn_prev        <= 1'b0;
        end else begin
            btn_sync0       <= btn_level;
            btn_sync1       <= btn_sync0;
            btn_prev        <= btn_sync1;
        end
    end

    wire [7:0] out_result;
    // CPU core 
    cpu_core u_cpu_core (
        .clk(clk),
        .rst_n(rst_n),
        .opcode(opcode),
        .instr(instr),
        .btn_edge(btn_edge),
        .inst_done(inst_done),
        .out(out_result)
    );
    assign uo_out  = out_result;
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // List all unused inputs to prevent warnings
    wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule
