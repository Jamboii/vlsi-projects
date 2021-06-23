`timescale 1ns / 1ps

// Model of a 2-port RAM
//  1 Write Port
//      +
//  1 Read Port
//
// Number of storage elements = 2^(LOG2_DEPTH)
module DIN_ram_model_1w1r
#( parameter
    [15:0] DIN_OFFSET = 665535,
    DIN_WORDLENGTH = 16,        // Q15.0
    DOUT_WORDLENGTH = 18,       // Q17.0,
    LOG2_DEPTH =  2
)
(
    input      [LOG2_DEPTH-1:0] DIN_IN_WADR,
    input                       DIN_IN_WEN,
    input      [DIN_WORDLENGTH-1:0] DIN_IN_WDAT,
    
    input      [LOG2_DEPTH-1:0] DIN_OUT_RADR,
    output     [DOUT_WORDLENGTH-1:0] DIN_OUT_RDAT,
    
    input      CLK
);

reg [DIN_WORDLENGTH-1:0]        dbuf[(1<<LOG2_DEPTH)-1:0];    // storage array

assign DIN_OUT_RDAT = dbuf[DIN_OUT_RADR];      // retrieve read data

// num_in_buf
always @ (posedge CLK)
begin
    if (DIN_IN_WEN)
        dbuf[DIN_IN_WADR]   <= DIN_IN_WDAT;             // store write data
        
end

endmodule