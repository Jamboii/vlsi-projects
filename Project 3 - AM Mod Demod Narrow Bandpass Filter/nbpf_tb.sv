`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
package math_pkg;
  //import dpi task      C Name = SV function name
  import "DPI-C" pure function real sin (input real rTheta);
endpackage : math_pkg

`define STEP_STIM (n >= 0)
`define SQ_STIM (n % 100)
`define RAMP_STIM (n) 
`define SIN_STIM ($rtoi((sin(6.2832*n*0.313)*32767.0)))
`define CHIRP_STIM ($rtoi(sin(6.2832*n*n/32768)*32767.0)) // 5kHz??? 
// can do chirp but make it go slower (want it to take longer), might not ever see it resonate because it has a pretty long requirement
// 
`define STIM (`SIN_STIM)

///////
module nbpf_tb();

// Needed for sin() function
import math_pkg::*;

//clk and rst generator 
reg clk;
reg rst_ = 0;
wire reset;
// const real pi = 3.14159265;
integer reset_count         = 0;

`define NUM_RESET_CYCLES    (10)
`define MAX_CYCLES          (1000)

assign reset = ~rst_;

initial
begin
    clk = 0;
    while (1)
        #5 clk = ~clk;  // toggle clk each 5 ns (100 MHz clock frequency)
end

always @ (posedge clk)
begin
    reset_count <= reset_count + 1;     // always use non-blocking assignment, '<=',
                                        // in sequential processes
    if (reset_count == `NUM_RESET_CYCLES)
        rst_ <= 1;
end
//stimulus generator 
logic signed [19:0] din;
// integer din;
bit DIN_RTR, DIN_RTS, DOUT_RTR, DOUT_RTS;
integer n;                      // n is the discrete-time index
integer m;

assign din = reset ? 0 : `STIM; // `STIM is a macro that can produce delta, step, ramp or chirp signals
assign DIN_RTS  = 1;
assign DOUT_RTR = 1;

always @ (posedge clk)
begin
    if (reset)
    begin
        n <= 0;
        m <= 0;
    end
    else
    begin
        // if (m % 4 == 0)
        n <= n + 1;
        // m <= m + 1;
    end
end
// instantiation of our direct form 1 nbpf
logic signed [15:0] dout;
nbpf filter
(
    .CLK(clk),
    .RESET(reset),
    .DIN_DAT(din),
    .DIN_RTS(DIN_RTS),
    .DIN_RTR(DIN_RTR),
    .DOUT_DAT(dout),
    .DOUT_RTS(DOUT_RTS),
    .DOUT_RTR(DOUT_RTR)
);
endmodule