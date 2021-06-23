`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 09/07/2020 04:59:36 PM
// Design Name: Project 1 Dot Box
// Module Name: dot_box
// Chris Henry, Sarah Fontana, Alex Benasutti
// Description: This module represents an automation of a dot-product calculation between two vectors
//////////////////////////////////////////////////////////////////////////////////

module dot_box_top
(
    // inputs: in_x, in_y, in_start, clk, reset
    input                       clk,        // system clock
    input                       reset,      // system reset
    input signed [7:0] [15:0]   IN_X,       // dot product input 1
    input signed [7:0] [15:0]   IN_Y,       // dot product input 2
    input                       IN_START,   // start pulse
    
    // outputs: out_dat, out_xfc, out_dat16
    output signed [31:0]        OUT_DAT,    // 32 bit dot product
    output signed [15:0]        OUT_DAT16,  // 16 bit shifted/rounded dot product
    output                      OUT_XFC     // "done" state indicator
);
    
    reg [2:0] count;                        // counter array indices? used as SELECT for mux
    reg [1:0] state;                        // state machine state
    
    reg signed [31:0] mul;                  // register for holding multiply block output
    reg signed [34:0] acc;                  // register for holding add block output
    reg signed [31:0] acc_clip;             // register for holding clipped block output
    reg signed [15:0] acc_shift_and_round;  // register for holding shifted and rounded output
    reg signed [15:0] acc_round;            // register whose sign will act as a "check" for rounding
    
    reg signed [15:0] MUX_X, MUX_Y;         // hold mux output values for multiplying
    
    reg round_up;                           // will indicate whether or not we round up our result
        
    // counter clock, reset goes back to 0
    always @ (posedge clk)
    begin
        if (reset || state == 2) begin  // reset states on reset or "done" state             
            count <= 0;
            mul <= 0;
            
            acc <= 0;
            acc_clip <= 0;
            acc_shift_and_round <= 0;
            acc_round <= 0;
            
            MUX_X <= 0;
            MUX_Y <= 0;
        end else if (state == 1) begin  // increment count/test vector index while "run"
            count <= count + 1;
        end
    end
    
    // state machine following clock edge
    always @ (posedge clk)
    begin
        if (reset)                                  // reset back to "idle"
            state <= 0;
        else
            case (state)
                0:  if (IN_START == 1)  state <= 1; // idle -> run
                    else                state <= 0; // idle -> idle
                    
                1:  if (count == 7) begin
                                        state <= 2; // run -> done
                    end else            state <= 1; // run -> run
                    
                2:                      state <= 0; // done -> idle
                
                default:                state <= 0;
            endcase
    end
    
    // combinatorial logic for when state machine is active
    always @ (*)
    begin
        // clear register on reset
        if (state == 1) begin
            // quick MUX for inputs by indexing the input arrays
            MUX_X = IN_X[count];
            MUX_Y = IN_Y[count];
            
            // find product of inputs and store to mul
            mul = $signed(MUX_X) * $signed(MUX_Y);
            
            // SOP for accumulator register
            acc = $signed(mul) + $signed(acc); // possibly 35 bit result
            
            // SATURATE: range of 32-bit two's complement: (-2^(n-1) -> 2^(n-1) - 1)
            if ($signed(acc) < -2.0**31.0) begin            // LOW SATURATION
                // clip off at -2^31
                acc_clip = $signed(32'h80000000);
                
                // set rounding variables to 0
                acc_round = 0; 
                round_up = 0; 
                
                $display("SATURATE LOW"); 
            end else if ($signed(acc) > 2.0**31.0-1) begin  // HIGH SATURATION
                // clip off at 2^31-1
                acc_clip = $signed(32'h7FFFFFFF); 
                
                // set rounding variables to 0
                acc_round = 0;
                round_up = 0; 
                
                $display("SATURATE HIGH"); 
            end else begin                                  // NO SATURATION   
                // grab least significant 32 bits              
                acc_clip = acc[31:0];  
                          
                // SHIFT AND ROUND
                acc_round = $signed(acc_clip[15:0]);
                round_up = $signed(acc_round) < 0 ? 1 : 0; // Transition from 7FFF -> -1 indicates 0.5 mark
            end
            
            // another round up check to see if we've reached the signed 16-bit postitive max
            if ($signed(acc_clip >>> 16) == 16'h7FFF) round_up = 0;
            
            // reach our Q16.16 result for OUT_DAT_16 by shifting and rounding if necessary
            acc_shift_and_round = $signed((acc_clip >>> 16) + round_up);
        end
    end
    
    // assign OUT_DAT as our 32-bit saturated/clipped result
    assign OUT_DAT = $signed(acc_clip);
    // assign OUT_DAT_16 as our shifted and rounded result
    assign OUT_DAT16 = $signed(acc_shift_and_round);
    // assign OUT_XFC as our "done" state
    assign OUT_XFC = (state == 2);
    
endmodule