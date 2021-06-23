`timescale 1ns / 1ps

module sum(
    input signed [19:0] x,
    input signed [19:0] y,
    output signed [20:0] z
);
assign z = x + y;
endmodule

module prod(
    input signed [19:0] coeff,
    input signed [19:0] din,
    output signed [19:0] dout
);
wire signed [39:0] dout_unshift;
assign dout_unshift = coeff * din;
assign dout = dout_unshift >>> 20;
endmodule

module z_minus_1(
    input signed [19:0] din,
    output reg signed [19:0] dout,
    
    input CLK,
    input RESET
);
always @ (posedge CLK)
if (RESET)
    dout <= 0;
else
    dout <= din;
endmodule

module npf
#
(
    M = 3    
)
(
    input CLK,
    input RESET,
    
    input  signed [19:0] DIN_DAT,
    input  DIN_RTS,
    output DIN_RTR,
    
    output signed [15:0] DOUT_DAT,
    output DOUT_RTS,
    input  DOUT_RTR
);
    parameter r = 0.99;
    parameter signed negative_r_squared = -0.98;
    parameter signed two_r_cos_ang_freq = 0.512;
    
    real signed coeffs[M:0] = {0, -1, 0.512, -0.98};
    
    real din_delayed[M:0];
    real prods[M:0];
    real sums[M:0];
    
    wire IN_XFC, OUT_XFC;
    
    assign DIN_RTS  = 1;
    assign DOUT_RTR = 1;
    
    assign IN_XFC  = (DIN_RTS & DIN_RTR);
    assign OUT_XFC = (DOUT_RTS & DOUT_RTR);
    
    z_minus_1 x_delay1( .din(DIN_DAT),        .dout(din_delayed[0]), .CLK(CLK), .RESET(RESET) );
    z_minus_1 x_delay2( .din(din_delayed[0]), .dout(din_delayed[1]), .CLK(CLK), .RESET(RESET) );
    
    prod x_prod1( .din(din_delayed[0]), .coeff(
    
    
endmodule
