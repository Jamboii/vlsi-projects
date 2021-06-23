`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// FIFO with Selvaggi-style input and output ports
// Width and depth are parameterized
// Depth = 2^LOG2_DEPTH
// Width = WORDLENGTH
//////////////////////////////////////////////////////////////////////////////////

module sp_fifo
#( parameter
	WORDLENGTH = 8,
	LOG2_DEPTH =  2
)
(
	input               	IN_RTS,    // IN I/F: upstream is ready-to-send
	output              	IN_RTR,    // IN I/F: FIFO is ready-to-receive
	input [WORDLENGTH-1:0]  IN_DAT,    // IN I/F: data bits
    
	output              	OUT_RTS,   // OUT I/F: FIFO is ready-to-send
	input               	OUT_RTR,   // OUT I/F: downstream is ready-to-receive
	output [WORDLENGTH-1:0] OUT_DAT,   // OUT I/F: data bits
    
	input               	clk,
	input               	reset
);
	reg [LOG2_DEPTH-1:0] wptr;
	reg [LOG2_DEPTH-1:0] rptr;         // read and write pointers
	wire wen;                          // write enable
	wire in_xfc;                        // in transfer complete, based on in RTS and RTR
	wire out_xfc;                       // out transfer complete, based on out RTS and RTR
	
	reg [LOG2_DEPTH:0] num_in_buf;     // how much stuff do we have in the fifo
	reg empty, full;                   // hey is the fifo full or empty
	
	// IN_RTR is like !full
	// OUT_RTS is like !empty
	assign IN_RTR  = (num_in_buf < (1<<LOG2_DEPTH)) && (!reset); // FIFO/RAM aint full yet, IF 0 DO NOT ALLOW ANY MORE WRITES
    assign OUT_RTS = (num_in_buf != 0) && (!reset);              // FIFO/RAM aint empty, got stuff in it, IF 0 DO NOT ALLOW ANY MORE READS
    
    // purple blocks xfc transfer logic
	// data is transfered when xfc= RTS&RTR=1
    assign in_xfc  = (IN_RTS & IN_RTR);   // this being = 1 allows writes
	assign out_xfc = (OUT_RTS & OUT_RTR); // this being = 1 allows reads
    
    assign wen = in_xfc;                  // write enable to RAM equivalent to in RTS?
        
    // Process to update num_in_buf
	always @ (posedge clk)
	begin
	   if (reset) begin
	       num_in_buf <= 0;
	   end else begin
           if (in_xfc && !out_xfc) begin // if we aint full 
               num_in_buf <= num_in_buf + 1;
           end
           
           if (out_xfc && !in_xfc) begin // if we aint empty               
               num_in_buf <= num_in_buf - 1;
           end
	   end
	end
	
	// Process to update wptr
	always @ (posedge clk)
	begin 
	   if (reset) begin
	       wptr <= 0;
	   end else begin
	       if (in_xfc) begin
	           wptr <= wptr + 1;
	       end
	   end
	end
	
	// Process to update rptr
	always @ (posedge clk)
	begin
	   if (reset) begin
	       rptr <= 0;
	   end else begin
	       if (out_xfc) begin
	           rptr <= rptr + 1;
	       end
	   end
	end
	
	// instantiate RAM 
	ram_model_1w1r 
	#(
	.WORDLENGTH(WORDLENGTH),
	.LOG2_DEPTH(LOG2_DEPTH)
    )
	myRAM
	(
	.IN_WADR(wptr), 
	.IN_WEN(wen), 
	.IN_WDAT(IN_DAT), 
	.OUT_RADR(rptr), 
	.OUT_RDAT(OUT_DAT), 
	.clk(clk)
	);

endmodule 

