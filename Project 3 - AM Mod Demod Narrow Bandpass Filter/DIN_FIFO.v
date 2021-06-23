`timescale 1ns / 1ps


module DIN_FIFO
# (parameter    [15:0] DIN_OFFSET = 665535,
                       LOG2_DEPTH =  2,     // UQ16.0
                       DIN_WORDLENGTH = 16, // Q15.0
                       DOUT_WORDLENGTH = 18 // Q17.0
)
(

	input        DIN_IN_RTS,                    // IN I/F: upstream is ready-to-send 
    output       DIN_IN_RTR,                    // IN I/F: upstream is ready-to-send
	input signed [DIN_WORDLENGTH-1:0] DIN_DAT,  // Q15.0
    
	output       DIN_OUT_RTS,	                  // OUT I/F: FIFO is ready-to-send
	input        DIN_OUT_RTR, 	                  // OUT I/F: downstream is ready-to-receive
	output signed [DOUT_WORDLENGTH-1:0] DOUT_DAT, // SUM Q17.0
    
	input               	CLK,
	input               	RESET
);

//Defining registers according to model
reg [LOG2_DEPTH-1:0] DIN_wptr;
reg [LOG2_DEPTH-1:0] DIN_rptr;
reg [LOG2_DEPTH  :0] DIN_num_in_buf;


//wires from RTS, RTR and rptr, num_in_buf
wire DIN_in_xfc;
wire DIN_out_xfc;

//assigning declared wires to inputs and outputs
assign DIN_in_xfc = DIN_IN_RTS & DIN_IN_RTR;
assign DIN_out_xfc = DIN_OUT_RTS & DIN_OUT_RTR;

//assigning values to IN_RTR and OUT_RTS
assign DIN_IN_RTR = (DIN_num_in_buf < (1<<LOG2_DEPTH)) & ~RESET;
assign DIN_OUT_RTS = (DIN_num_in_buf > 0) & ~RESET;

always@ (posedge CLK)
begin
	if (RESET) //reset all values in fifo
	begin
    	DIN_num_in_buf <= 0;  // initially num_in_buf gets zero
    	DIN_rptr <= 0;        // initially rptr gets zero
    	DIN_wptr <= 0;        // initially wptr gets zero
	end
	else
	begin
    	if (DIN_in_xfc & ~DIN_out_xfc)  //if in_xfc increment buffer like fifo occupancy
        	DIN_num_in_buf <= DIN_num_in_buf+1;
    	else if (~DIN_in_xfc & DIN_out_xfc)      //if out_xfc decrement buffer
        	DIN_num_in_buf <= DIN_num_in_buf-1;
    	if (DIN_in_xfc)                     // if in_xfc increment write parameter
    	begin
        	if (LOG2_DEPTH == 0)      // check for fifo depth
            	DIN_wptr <= 0;          // if no depth set wptr gets zero
        	else
            	DIN_wptr <= DIN_wptr+1;     // else increment wptr
    	end
    	if (DIN_out_xfc)                  // if out_xfc increment write parameter
        	if (LOG2_DEPTH == 0)    // check for fifo depth
            	DIN_rptr <= 0;        // if no depth set rptr gets zero
        	else
            	DIN_rptr <= DIN_rptr+1;   // else increment rptr
 	end
end

//SUM

// Instantiate RAM model
DIN_ram_model_1w1r
#(
.DIN_OFFSET(DIN_OFFSET),
.DIN_WORDLENGTH(DIN_WORDLENGTH),
.DOUT_WORDLENGTH(DOUT_WORDLENGTH),
.LOG2_DEPTH(LOG2_DEPTH)
)
DIN_ram_model_lwlr
(
.DIN_IN_WADR(DIN_wptr),
.DIN_IN_WEN(DIN_in_xfc),
.DIN_IN_WDAT(DIN_DAT),
.DIN_OUT_RADR(DIN_rptr),
.DIN_OUT_RDAT(DOUT_DAT),
.CLK(CLK)
);

endmodule