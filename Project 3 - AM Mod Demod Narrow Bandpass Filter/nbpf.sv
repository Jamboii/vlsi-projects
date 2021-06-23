`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////
// actual nbpf - direct form 2 with da one multipleri
//////////////////////////////////////////////////////////////////////////////////////
module nbpf
(
    input CLK,
    input RESET,
    
    input signed [19:0] DIN_DAT, // Q17.2
    input  DIN_RTS,
    output DIN_RTR,
    
    output signed [15:0] DOUT_DAT,
    output DOUT_RTS,
    input  DOUT_RTR
);


bit IN_XFC, OUT_XFC;
logic [1:0] state;


reg  SP_IN_RTS;
wire SP_IN_RTR;
reg  [19:0] SP_IN_DAT;
wire SP_OUT_RTS;
wire SP_OUT_RTR;
wire [19:0] SP_OUT_DAT;

sp_fifo
# (
    .WORDLENGTH(20),
    .LOG2_DEPTH(16)
)
u_nbpf_sp_fifo
(
    .IN_RTS(DIN_RTS),
    .IN_RTR(DIN_RTR),
    .IN_DAT(DIN_DAT),
    .OUT_RTS(SP_OUT_RTS),
    .OUT_RTR(SP_OUT_RTR),
    .OUT_DAT(SP_OUT_DAT),
    .clk(CLK),
    .reset(RESET)
);


assign SP_OUT_RTR = (state == 0);            // state == idle
// assign DIN_RTR  = (state == 0);
assign DOUT_RTS = (state == 2 || state == 3); // state = run_2 or state = wait

assign IN_XFC  = (SP_OUT_RTS & SP_OUT_RTR);
// assign IN_XFC  = (DIN_RTS & DIN_RTR);
assign OUT_XFC = (DOUT_RTS & DOUT_RTR);


logic signed [25:0] din_delayed_w[1:0];  // w(n) Q23.2 z^-1 delay registers
logic signed [41:0] prods[1:0];          // multiply block registers Q0.15 * Q23.2 = Q24.17 --> 42 bits

logic signed [34:0] sums_x_padded;       // DIN_DAT Q17.2 -> Q17.17, for the sum of w(n)
logic signed [42:0] sums_w1_minus_w2;    // 2rcos(w0)*w(n-1) - r^2*w(n-2) --> Q24.17 - Q24.17 = Q25.17
logic signed [42:0] sums_w;              // Q25.17
logic signed [42:0] sums_w_round;        // Q25.17
logic signed [27:0] sums_w_round_shift;  // Q25.2
logic signed [25:0] sums_w_out;          // Q23.2 w(n)

logic signed [26:0] sums_w_minus_w2;     // w(n) - w(n-2) --> Q23.2 - Q23.2 = Q24.2
logic signed [15:0] sums_y;              // y(n) = w(n) - w(n-2), take 16 MSB - 1

// coefficients for each multiplier { 2rcos(w0)*y(n-1), -r^2*y(n-2) }
// probably have this array as an input to the module in the future
shortreal coeffs[1:0] = {-0.9801, 0.512461709302991};

reg signed [15:0] icoeffs[1:0];

assign icoeffs[0] = $rtoi(coeffs[0] * 32767);
assign icoeffs[1] = $rtoi(coeffs[1] * 32767);

// Round this sum result 15 decimal places --> Q25.17 to Q25.2
assign sums_w_round       = sums_w + 43'h4000;
// Prepare the result to be shifted with a Q25.2 number
assign sums_w_round_shift = sums_w_round[42:15];

///////////////////////////////////////////////////////////////////////////////////////
// delay blocks
///////////////////////////////////////////////////////////////////////////////////////

z_minus_1_nbpf #( .NUM_BITS(26) ) delay_w_0( .din(sums_w_out),       .dout(din_delayed_w[0]), .CLK_EN(IN_XFC), .CLK(CLK), .RESET(RESET) ); // w(n)   -> w(n-1) Q23.2
z_minus_1_nbpf #( .NUM_BITS(26) ) delay_w_1( .din(din_delayed_w[0]), .dout(din_delayed_w[1]), .CLK_EN(IN_XFC), .CLK(CLK), .RESET(RESET) ); // w(n-1) -> w(n-2) Q23.2

///////////////////////////////////////////////////////////////////////////////////////
// combinational logic for difference equation
///////////////////////////////////////////////////////////////////////////////////////
// y(n) = x(n) - x(n-2) + 2rcos(w0)*y(n-1) - r^2*y(n-2)

// clock block for state machine 
always @(posedge CLK) begin
    if (RESET)                                // reset back to "idle"
        state <= 0;
    else
        case (state)
            0:  if (IN_XFC == 1)  state <= 1; // idle -> run_1
                else              state <= 0; // idle -> idle
                
            1:                    state <= 2; // run_1 -> run_2
                
            2:                    state <= 3; // run_2 -> wait
            
            3:  if (OUT_XFC == 1) state <= 0; // wait -> idle
                else              state <= 3;
            
            default:              state <= 0;
        endcase
end

// combinational block for multiply 
always_comb begin
    // MULTIPLY
    if (RESET) begin
        prods[0] = 0;
        prods[1] = 0;
        
        sums_w_out       = 0;
        din_delayed_w[0] = 0;
        din_delayed_w[1] = 0;
    end else if (state == 1) // run_1
        prods[0] = $signed(icoeffs[0]) * $signed(din_delayed_w[0]);
    else if (state == 2) begin     // run_2
        prods[1] = $signed(icoeffs[1]) * $signed(din_delayed_w[1]);
        /////////
        // logic for 2rcos(w0)*w(n-1) - r^2*w(n-2)
        // Find the product 2rcos(w0)*w(n-1) --> Q0.15 * Q23.2 = Q24.17 --> icoeffs[0] * din_delayed_y[0] = prods[0]
        // prods[0] = $signed(icoeffs[0]) * $signed(din_delayed_w[0]);
        // Find the product -r^2*w(n-2) --> Q0.15 * Q23.2 = Q24.17 --> icoeffs[1] * din_delayed[1] = prods[1]
        // prods[1] = $signed(icoeffs[1]) * $signed(din_delayed_w[1]);
        /// Find the difference of these two products 2rcos(w0)*w(n-1) + -r^2*w(n-2) --> Q24.17 - Q24.17 = Q25.17 --> prods[0] - prods[1] = sums_w1_minus_w2
        sums_w1_minus_w2 = $signed(prods[0]) + $signed(prods[1]);
        
        /////////
        // logic for w(n) = x(n) + 2rcos(w0)*w(n-1) - r^2*w(n-2)
        // Pad x(n) with 15 zeroes --> Q17.2 to Q17.17 = sums_x_padded
        sums_x_padded = $signed({SP_OUT_DAT, 15'b0});
        // sums_x_padded = $signed({DIN_DAT, 15'b0});
        // Add padded x(n) to sums_w1_minus_w2 --> Q17.17 + Q25.17 = Q25.17
        sums_w = $signed(sums_x_padded) + $signed(sums_w1_minus_w2);
        // Saturate this sum result if necessary (ITS WRONG IF IT ACTUALLY SATURATES)
        if (sums_w_round_shift > $signed(26'h1FFFFFF)) // 00_0000_0000_0000_0000_0000_0000
            sums_w_out = $signed(26'h1FFFFFF);
        else if (sums_w_round_shift < $signed(26'h2000000))
            sums_w_out = $signed(26'h2000000);
        else
            // Shift this sum result 2 places --> Q25.2 to Q23.2
            sums_w_out = sums_w_round_shift[25:0];
        
        /////////
        // logic for y(n) = w(n) - w(n-2) --> Q23.2 - Q23.2 = Q24.2
        sums_w_minus_w2 = $signed(sums_w_out) - $signed(din_delayed_w[1]);
        // logic for converting Q24.2 into Q0.15
        sums_y = $signed(sums_w_minus_w2[25:10]);
    end
end

assign DOUT_DAT = $signed(sums_y);

endmodule

//////////////////////////////////////////////////////////////////////////////////////
// actual nbpf - direct form 2
//////////////////////////////////////////////////////////////////////////////////////
module nbpf_direct2
(
    input CLK,
    input RESET,
    
    input signed [19:0] DIN_DAT, // Q17.2
    input  DIN_RTS,
    output DIN_RTR,
    
    // output signed [25:0] DOUT_DAT // Q23.2 FOR NOW
    output signed [15:0] DOUT_DAT,
    output DOUT_RTS,
    input  DOUT_RTR
);


bit IN_XFC, OUT_XFC;

assign DIN_RTR  = DOUT_RTR;
assign DOUT_RTS = DIN_RTS;

assign IN_XFC  = (DIN_RTS & DIN_RTR);
assign OUT_XFC = (DOUT_RTS & DOUT_RTR); 

/*
THE ALGORITHM???

the difference equation: y(n) = 2rcos(w0)*y(n-1) - r^2*y(n-2) + (x(n) - x(n-2))
y(n) = w(n) - w(n-2)
w(n) = x(n) + 2rcos(w0)*w(n-1) - r^2*w(n-2)

sums_w = DIN_DAT + icoeffs[0]*din_delayed_w[0] - icoeffs[1]*din_delayed_w[1] --> DIN_DAT + prods[0] - prods[1]
Q23.2  = Q17.2 + Q0.15*Q23.2 - Q0.15*Q23.2 --> 
Q23.2  = Q17.2 + Q24.17 - Q24.17 --> PAD Q17.2 to Q17.17 -> sums_x_padded + sums_w1_minus_w2
Q23.2  = Q17.17 + Q25.17 
Q23.2  = Q25.17
Saturate and round --> Q25.17 to Q23.2
sums_w_round           Q25.17
sums_w_round_shift     Q25.2
sums_w                 Q23.2

sums_y = sums_w - din_delayed_w[1] --> sums_w_minus_w2
Q0.15  = Q23.2 - Q23.2
Q0.15  = Q24.2
sums_y = sums_w_minus_w2[26:11]

multiply block -> counter = 2 pleaSE?

*/

logic signed [25:0] din_delayed_w[1:0];  // w(n) Q23.2 z^-1 delay registers
logic signed [41:0] prods[1:0];          // multiply block registers Q0.15 * Q23.2 = Q24.17 --> 42 bits

logic signed [34:0] sums_x_padded;       // DIN_DAT Q17.2 -> Q17.17, for the sum of w(n)
logic signed [42:0] sums_w1_minus_w2;    // 2rcos(w0)*w(n-1) - r^2*w(n-2) --> Q24.17 - Q24.17 = Q25.17
logic signed [42:0] sums_w;              // Q25.17
logic signed [42:0] sums_w_round;        // Q25.17
logic signed [27:0] sums_w_round_shift;  // Q25.2
logic signed [25:0] sums_w_out;          // Q23.2 w(n)

logic signed [26:0] sums_w_minus_w2;     // w(n) - w(n-2) --> Q23.2 - Q23.2 = Q24.2
logic signed [15:0] sums_y;              // y(n) = w(n) - w(n-2), take 16 MSB - 1

// MULTIPLY
logic [1:0] count;
logic [1:0] state;

// coefficients for each multiplier { 2rcos(w0)*y(n-1), -r^2*y(n-2) }
// probably have this array as an input to the module in the future
shortreal coeffs[1:0] = {-0.9801, 0.512461709302991};

reg signed [15:0] icoeffs[1:0];

assign icoeffs[0] = $rtoi(coeffs[0] * 32767);
assign icoeffs[1] = $rtoi(coeffs[1] * 32767);

// Round this sum result 15 decimal places --> Q25.17 to Q25.2
assign sums_w_round       = sums_w + 43'h4000;
// Prepare the result to be shifted with a Q25.2 number
assign sums_w_round_shift = sums_w_round[42:15];

///////////////////////////////////////////////////////////////////////////////////////
// delay blocks
///////////////////////////////////////////////////////////////////////////////////////

z_minus_1_nbpf #( .NUM_BITS(26) ) delay_w_0( .din(sums_w_out),       .dout(din_delayed_w[0]), .CLK_EN(IN_XFC), .CLK(CLK), .RESET(RESET) ); // w(n)   -> w(n-1) Q23.2
z_minus_1_nbpf #( .NUM_BITS(26) ) delay_w_1( .din(din_delayed_w[0]), .dout(din_delayed_w[1]), .CLK_EN(IN_XFC), .CLK(CLK), .RESET(RESET) ); // w(n-1) -> w(n-2) Q23.2

///////////////////////////////////////////////////////////////////////////////////////
// combinational logic for difference equation
///////////////////////////////////////////////////////////////////////////////////////
// y(n) = x(n) - x(n-2) + 2rcos(w0)*y(n-1) - r^2*y(n-2)

/*
take the biggest number that you can get
input is --> picture --> adjust Q23.2 output to Q0.15
- saturating and rounding shouldnt really matter but do it just to be safe
- we'll have a Q25.17, 43 bits [42:0]
- MSB doesn't matter, take [41:26]

performance should not be different, results identical
*/
    
always_comb begin
    /////////
    // logic for 2rcos(w0)*w(n-1) - r^2*w(n-2)
    // Find the product 2rcos(w0)*w(n-1) --> Q0.15 * Q23.2 = Q24.17 --> icoeffs[0] * din_delayed_y[0] = prods[0]
    prods[0] = $signed(icoeffs[0]) * $signed(din_delayed_w[0]);
    // Find the product -r^2*w(n-2) --> Q0.15 * Q23.2 = Q24.17 --> icoeffs[1] * din_delayed[1] = prods[1]
    prods[1] = $signed(icoeffs[1]) * $signed(din_delayed_w[1]);
    /// Find the difference of these two products 2rcos(w0)*w(n-1) + -r^2*w(n-2) --> Q24.17 - Q24.17 = Q25.17 --> prods[0] - prods[1] = sums_w1_minus_w2
    sums_w1_minus_w2 = $signed(prods[0]) + $signed(prods[1]);
    
    /////////
    // logic for w(n) = x(n) + 2rcos(w0)*w(n-1) - r^2*w(n-2)
    // Pad x(n) with 15 zeroes --> Q17.2 to Q17.17 = sums_x_padded
    sums_x_padded = $signed({DIN_DAT, 15'b0});
    // Add padded x(n) to sums_w1_minus_w2 --> Q17.17 + Q25.17 = Q25.17
    sums_w = $signed(sums_x_padded) + $signed(sums_w1_minus_w2);
    // Saturate this sum result if necessary (ITS WRONG IF IT ACTUALLY SATURATES)
    if (sums_w_round_shift > $signed(26'h1FFFFFF)) // 00_0000_0000_0000_0000_0000_0000
        sums_w_out = $signed(26'h1FFFFFF);
    else if (sums_w_round_shift < $signed(26'h2000000))
        sums_w_out = $signed(26'h2000000);
    else
        // Shift this sum result 2 places --> Q25.2 to Q23.2
        sums_w_out = sums_w_round_shift[25:0];
    
    /////////
    // logic for y(n) = w(n) - w(n-2) --> Q23.2 - Q23.2 = Q24.2
    sums_w_minus_w2 = $signed(sums_w_out) - $signed(din_delayed_w[1]);
    // logic for converting Q24.2 into Q0.15
    sums_y = $signed(sums_w_minus_w2[25:10]);
end

// assign DOUT_DAT = $signed(sums_xplusy_out);
assign DOUT_DAT = $signed(sums_y);

endmodule

///////////////////////////////////////////////////////////////////////////////////////
// narrow bandpass filter module - direct form 1
///////////////////////////////////////////////////////////////////////////////////////

module nbpf_direct1
(
    input CLK,
    input RESET,
    
    input signed [19:0] DIN_DAT, // Q17.2
    // input  DIN_RTS,
    // output DIN_RTR,
    
    // output signed [25:0] DOUT_DAT // Q23.2 FOR NOW
    output logic signed [15:0] DOUT_DAT
    // output DOUT_RTS,
    // input  DOUT_RTR
);

/*
bit IN_XFC, OUT_XFC;

assign DIN_RTR  = 1;
assign DOUT_RTS = 1;

assign IN_XFC  = (DIN_RTS & DIN_RTR);
assign OUT_XFC = (DOUT_RTS & DOUT_RTR); 
*/

/*
THE ALGORITHM???

the difference equation: y(n) = 2rcos(w0)*y(n-1) - r^2*y(n-2) + (x(n) - x(n-2))

to make sure we account for that gain of 50 due to w0, we need to make y(n-1) and y(n-2) Q23.2 reals
therefore,

// prod blocks will have same output: Q0.15 * Q23.2 = Q24.17

probably better to have separate adder blocks for the whole thing 
> Q17.2  - Q17.2  = Q18.2  --> PAD TO Q18.17
> Q24.17 - Q24.17 = Q25.17  
> Q25.17 + Q18.17 = Q25.17 --> SAT AND ROUND TO Q23.2

saturate blocks
> Q18.2  --> Q18.17
> Q25.17 --> Q23.2

===============================================================

y(n)  = 2rcos(w0)*y(n-1) - r^2  *y(n-2) + (x(n) - x(n-2))
Q23.2 = Q0.15    *Q23.2  - Q0.15*Q23.2  + (Q17.2 - Q17.2)
Q23.2 = Q24.17           - Q24.17       + Q18.2

pad the Q18.2 difference with 15 extra zeroes ( >> 15 ) to make same fixed point representation

Q23.2 = Q24.17           - Q24.17       + Q18.17
Q23.2 = Q25.17           + Q18.17
Q23.2 = Q25.17

idk how u do this again but somehow we can saturate and round this back to Q25.17

convert Q25.17 -> Q23.2 and round?? the shift and round scenario

convert Q25.17 -> Q25.2
Q25.2 -> Q23.2
zround = zin + 43'h4000
zroundshift = zround[42:15]

saturation code
if not saturable

zout = zroundshift[25:0]

b000_0000_0000_0000_0000_0000_000(.)0_0.100_0000_0000_0000
+                                  
--------------------------------------------------------
*/

logic signed [19:0] din_delayed_x[1:0];  // x(n) Q17.2 z^-1 delay registers
logic signed [25:0] din_delayed_y[1:0];  // y(n) Q23.2 z^-1 delay registers
logic signed [41:0] prods[1:0];          // multiply block registers for those two coefficients that we need to pay attention to --> Q0.15 * Q23.2 = Q24.17 --> 42 bits
logic signed [20:0] sums_xminusx;        // x(n) - x(n-2) register Q18.2
logic signed [35:0] sums_xminusx_padded; // Q18.2 --> Q18.17

logic signed [42:0] sums_yminusy;        // 2rcos(w0)*y(n-1) - r^2*y(n-2) register Q25.17

logic signed [42:0] sums_xplusy;         // sum of the two things above Q18.17 + Q25.17 = Q25.17
logic signed [42:0] sums_xplusy_round;   // ^^ Q25.17 --> Q25.2
logic signed [27:0] sums_xplusy_round_shift; // ^^ Q25.2 --> Q23.2
logic signed [25:0] sums_xplusy_out;     // Q23.2

// coefficients for each multiplier { 2rcos(w0)*y(n-1), -r^2*y(n-2) }
// probably have this array as an input to the module in the future
// shortreal coeffs[1:0] = {0.512461709302991, -0.9801};;
shortreal coeffs[1:0] = {-0.9801, 0.512461709302991};

reg signed [15:0] icoeffs[1:0];

assign icoeffs[0] = $rtoi(coeffs[0] * 32767);
assign icoeffs[1] = $rtoi(coeffs[1] * 32767);

// Round this sum result 15 decimal places --> Q25.17 to Q25.2
assign sums_xplusy_round       = sums_xplusy + 43'h4000;
// Prepare the result to be shifted with a Q25.2 number
assign sums_xplusy_round_shift = sums_xplusy_round[42:15]; 

///////////////////////////////////////////////////////////////////////////////////////
// delay blocks
///////////////////////////////////////////////////////////////////////////////////////

z_minus_1_nbpf #( .NUM_BITS(20) ) delay_x_0( .din(DIN_DAT),                 .dout(din_delayed_x[0]), .CLK(CLK), .RESET(RESET) ); // x(n-1) Q17.2 == Q23.2
z_minus_1_nbpf #( .NUM_BITS(20) ) delay_x_1( .din(din_delayed_x[0]),        .dout(din_delayed_x[1]), .CLK(CLK), .RESET(RESET) ); // x(n-2) Q17.2

z_minus_1_nbpf #( .NUM_BITS(26) ) delay_y_0( .din(sums_xplusy_out),         .dout(din_delayed_y[0]), .CLK(CLK), .RESET(RESET) ); // y(n-1) Q23.2
z_minus_1_nbpf #( .NUM_BITS(26) ) delay_y_1( .din(din_delayed_y[0]),        .dout(din_delayed_y[1]), .CLK(CLK), .RESET(RESET) ); // y(n-2) Q23.2

///////////////////////////////////////////////////////////////////////////////////////
// combinational logic for difference equation
///////////////////////////////////////////////////////////////////////////////////////
// y(n) = x(n) - x(n-2) + 2rcos(w0)*y(n-1) - r^2*y(n-2)

/*
take the biggest number that you can get
input is --> picture --> adjust Q23.2 output to Q0.15
- saturating and rounding shouldnt really matter but do it just to be safe
- we'll have a Q25.17, 43 bits [42:0]
- MSB doesn't matter, take [41:26]

performance may be diff values should be identical

make direct form 2

use 1 multiplier - takes state machine
*/

always_comb begin
    /////////
    // logic for x(n) - x(n-2)
    // Find the difference x(n) - x(n-2) --> Q17.2 - Q17.2 = Q18.2 --> DIN_DAT - din_delayed_x[1] = sums_xminusx
    sums_xminusx = $signed(DIN_DAT) - $signed(din_delayed_x[1]);
    // Pad the result of x(n) - x(n-2) with 15 zeroes --> Q18.2 to Q18.17 --> sums_xminusx padded = sums_xminusx_padded
    sums_xminusx_padded = $signed({sums_xminusx, 15'b0});
    
    /////////
    // logic for 2rcos(w0)*y(n-1) - r^2*y(n-2)
    // Find the product 2rcos(w0)*y(n-1) --> Q0.15 * Q23.2 = Q24.17 --> icoeffs[0] * din_delayed_y[0] = prods[0]
    prods[0] = $signed(icoeffs[0]) * $signed(din_delayed_y[0]);
    // Find the product -r^2*y(n-2) --> Q0.15 * Q23.2 = Q24.17 --> icoeffs[1] * din_delayed[1] = prods[1]
    prods[1] = $signed(icoeffs[1]) * $signed(din_delayed_y[1]);
    
    // Find the difference of these two products 2rcos(w0)*y(n-1) + -r^2*y(n-2) --> Q24.17 - Q24.17 = Q25.17 --> prods[0] - prods[1] = sums_yminusy
    sums_yminusy = $signed(prods[0]) + $signed(prods[1]);
    
    /////////
    // logic for x(n) - x(n-2) + 2rcos(w0)*y(n-1) - r^2*y(n-2)
    // Add the two earlier results to find y(n) --> Q18.17 + Q25.17 = Q25.17 --> sums_xminusx_padded + sums_yminusy = sums_xplusy
    sums_xplusy = $signed(sums_xminusx_padded) + $signed(sums_yminusy);
    
    // Saturate this sum result if necessary (ITS WRONG IF IT ACTUALLY SATURATES)
    if (sums_xplusy_round_shift > $signed(26'h1FFFFFF)) // 00_0000_0000_0000_0000_0000_0000
        sums_xplusy_out = $signed(26'h1FFFFFF);
    else if (sums_xplusy_round_shift < $signed(26'h2000000))
        sums_xplusy_out = $signed(26'h2000000);
    else
        // Shift this sum result 3 places --> Q25.2 to Q23.2
        sums_xplusy_out = sums_xplusy_round_shift[25:0];
end

// assign DOUT_DAT = $signed(sums_xplusy_out);
assign DOUT_DAT = $signed(sums_xplusy[41:26]);

endmodule

///////////////////////////////////////////////////////////////////////////////////////
// delay block module
///////////////////////////////////////////////////////////////////////////////////////
module z_minus_1_nbpf
#(parameter NUM_BITS=20
)
(
    input signed [(NUM_BITS-1):0] din,        // Q17.2 for x(n), Q23.2 for y(n)
    output reg signed [(NUM_BITS-1):0] dout,  // Q17.2 for x(n), Q23.2 for y(n)
    input CLK_EN,
    input CLK,
    input RESET
    
);

always @ (posedge CLK)
if (RESET)
    dout <= 0;
else if (CLK_EN)
    dout <= din;
endmodule

///////////////////////////////////////////////////////////////////////////////////////
// fifo block module
///////////////////////////////////////////////////////////////////////////////////////
/*
sp_fifo
# (
    .WORDLENGTH(20),
    .LOG2_DEPTH(4)
)
u_nbpf_sp_fifo
(
    .IN_RTS(DIN_RTS),
    .IN_RTR(DIN_RTR),
    .IN_DAT(DIN_DAT),
    .OUT_RTS(SP_OUT_RTS),
    .OUT_RTR(SP_OUT_RTR),
    .OUT_DAT(SP_OUT_DAT),
    .clk(CLK),
    .reset(RESET)
);
*/
module sp_fifo
# 
(parameter LOG2_DEPTH =  4,   // UQ16.0
           WORDLENGTH = 20    // Q17.2
)
(

	input         IN_RTS,                   // IN I/F: upstream is ready-to-send 
    output        IN_RTR,                   // IN I/F: upstream is ready-to-send
	input signed  [WORDLENGTH-1:0] IN_DAT,  // Q17.2
    
	output        OUT_RTS,	                // OUT I/F: FIFO is ready-to-send
	input         OUT_RTR, 	                // OUT I/F: downstream is ready-to-receive
	output signed [WORDLENGTH-1:0] OUT_DAT, // NBPF Q17.2
    
	input         clk,
	input         reset
);

//Defining registers according to model
reg [LOG2_DEPTH-1:0] wptr;
reg [LOG2_DEPTH-1:0] rptr;
reg [LOG2_DEPTH  :0] num_in_buf;

//wires from RTS, RTR and rptr, num_in_buf
wire in_xfc;
wire out_xfc;

//assigning declared wires to inputs and outputs
assign in_xfc  = IN_RTS & IN_RTR;
assign out_xfc = OUT_RTS & OUT_RTR;

//assigning values to IN_RTR and OUT_RTS
assign IN_RTR  = (num_in_buf < (1<<LOG2_DEPTH)) & ~reset;
assign OUT_RTS = (num_in_buf > 0) & ~reset;

always@ (posedge clk)
begin
	if (reset) //reset all values in fifo
	begin
    	num_in_buf <= 0;  // initially num_in_buf gets zero
    	rptr <= 0;        // initially rptr gets zero
    	wptr <= 0;        // initially wptr gets zero
	end
	else
	begin
    	if (in_xfc & ~out_xfc)           // if in_xfc increment buffer like fifo occupancy
        	num_in_buf <= num_in_buf+1;
    	else if (~in_xfc & out_xfc)      //if out_xfc decrement buffer
        	num_in_buf <= num_in_buf-1;
    	if (in_xfc)                      // if in_xfc increment write parameter
    	begin
        	if (LOG2_DEPTH == 0)         // check for fifo depth
            	wptr <= 0;               // if no depth set wptr gets zero
        	else
            	wptr <= wptr+1;          // else increment wptr
    	end
    	if (out_xfc)                     // if out_xfc increment write parameter
        	if (LOG2_DEPTH == 0)         // check for fifo depth
            	rptr <= 0;               // if no depth set rptr gets zero
        	else
            	rptr <= rptr+1;          // else increment rptr
 	end
end

// Instantiate RAM model
ram_model_1w1r
#(
.WORDLENGTH(WORDLENGTH),
.LOG2_DEPTH(LOG2_DEPTH)
)
nbpf_ram
(
.IN_WADR(wptr),
.IN_WEN(in_xfc),
.IN_WDAT(IN_DAT),
.OUT_RADR(rptr),
.OUT_RDAT(OUT_DAT),
.CLK(clk)
);

endmodule

///////////////////////////////////////////////////////////////////////////////////////
// RAM block module
///////////////////////////////////////////////////////////////////////////////////////
// Model of a 2-port RAM
//  1 Write Port
//      +
//  1 Read Port
//
// Number of storage elements = 2^(LOG2_DEPTH)
module ram_model_1w1r
#( parameter WORDLENGTH = 20,      //Q17.2
             LOG2_DEPTH =  4
)
(
    input      [LOG2_DEPTH-1:0] IN_WADR,
    input                       IN_WEN,
    input      [WORDLENGTH-1:0] IN_WDAT,
    
    input      [LOG2_DEPTH-1:0] OUT_RADR,
    output     [WORDLENGTH-1:0] OUT_RDAT,
    
    input      CLK
);

reg [WORDLENGTH-1:0]        dbuf[(1<<LOG2_DEPTH)-1:0];    // storage array

assign OUT_RDAT = dbuf[OUT_RADR];      // retrieve read data

// num_in_buf
always @ (posedge CLK)
begin
    if (IN_WEN)
        dbuf[IN_WADR]   <= IN_WDAT;    // store write data
end

endmodule
