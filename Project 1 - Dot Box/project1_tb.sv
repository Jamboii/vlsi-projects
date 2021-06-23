`timescale 1ns / 1ps

module tb ();

////////////////////////////////////////////////////////////////////////    
// Clock & reset generator
////////////////////////////////////////////////////////////////////////
reg     clk;
reg     rst_ = 0;
wire    reset;

integer reset_count = 0;
`define NUM_RESET_CYCLES (10)

wire    sck_falling_edge;

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
////////////////////////////////////////////////////////////////////////    


////////////////////////////////////////////////////////////////////////    
// Open the file at simulation startup
//
integer fd_in;

initial
begin
    fd_in = $fopen( "../../../../../scripts/dot_box_stim_resp_1", "r" );
    if (fd_in == 0)
    begin
        $display( "Couldn't open file for read" );
        $finish;
    end
end
////////////////////////////////////////////////////////////////////////    

////////////////////////////////////////////////////////////////////////    
// Read in stimulus vectors, and golden response from the file
////////////////////////////////////////////////////////////////////////
reg  signed[7:0][15:0] stim_IN_X;
reg  signed[7:0][15:0] stim_IN_Y;
wire                   stim_IN_START;

wire              resp_OUT_XFC;
wire signed[31:0] resp_OUT_DAT;
wire signed[15:0] resp_OUT_DAT16;

reg  signed[31:0] gold_OUT_DAT;
reg  signed[15:0] gold_OUT_DAT16;

string  the_line;
integer num_items;

`define TB_STATE_IDLE   (0)
`define TB_STATE_START  (1)
`define TB_STATE_WAIT   (2)
`define TB_STATE_DONE   (3)

integer tb_state;

assign stim_IN_START = (tb_state == `TB_STATE_START);

always @ (posedge clk)
begin
    if (reset)
        tb_state <= `TB_STATE_IDLE;
    else
        case (tb_state)
            `TB_STATE_IDLE:
                tb_state <= `TB_STATE_START;
                
            `TB_STATE_START:
                tb_state <= `TB_STATE_WAIT;
            `TB_STATE_WAIT:
                if (resp_OUT_XFC)
                    tb_state <= `TB_STATE_DONE;
            `TB_STATE_DONE:
                tb_state <= `TB_STATE_IDLE;
        endcase
end

integer test_status;
        
always @ (posedge clk)
begin
    if (reset)
    begin
        stim_IN_X       <= 0;
        stim_IN_Y       <= 0;
        gold_OUT_DAT    <= 0;
        gold_OUT_DAT16  <= 0;
    end
    else
    begin
        if (tb_state == `TB_STATE_START)
        begin
            num_items=$fgets( the_line, fd_in );
            
            if (num_items == 0)
            begin
                $display( "***** ----> PASS <---- ***** !!!\n" );
                #25 $finish;
            end
            else if (the_line[0] != "/")
            begin
                $sscanf( the_line, "%h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h", 
                    stim_IN_X[0],
                    stim_IN_X[1],
                    stim_IN_X[2],
                    stim_IN_X[3],
                    stim_IN_X[4],
                    stim_IN_X[5],
                    stim_IN_X[6],
                    stim_IN_X[7],
                    stim_IN_Y[0],
                    stim_IN_Y[1],
                    stim_IN_Y[2],
                    stim_IN_Y[3],
                    stim_IN_Y[4],
                    stim_IN_Y[5],
                    stim_IN_Y[6],
                    stim_IN_Y[7],
                    gold_OUT_DAT, gold_OUT_DAT16 );
            end
        end
        else if (resp_OUT_XFC)
        begin
            $display("checking 32 ");
            if (gold_OUT_DAT == resp_OUT_DAT)
                test_status = 1;
            else                
            begin
                $display( "***** ----> FAIL on %08h, got %08h <---- ***** !!!\n", gold_OUT_DAT, resp_OUT_DAT );
                #25 $finish;
            end
            $display("checking 16\n");
            if (gold_OUT_DAT16 == resp_OUT_DAT16)
                test_status = 1;
            else
            begin
                $display( "***** ----> FAIL on %08h, got %08h <---- ***** !!!\n", gold_OUT_DAT16, resp_OUT_DAT16 );
                #25 $finish;
            end
        end
    end
end
////////////////////////////////////////////////////////////////////////    


////////////////////////////////////////////////////////////////////////    
// Instantiate DUT
//

dot_box_top u_dot_box_top
(
    .clk      (clk      ),
    .reset    (reset    ),
    .IN_X     (stim_IN_X     ),
    .IN_Y     (stim_IN_Y     ),
    .IN_START (stim_IN_START ),
    .OUT_DAT  (resp_OUT_DAT  ),
    .OUT_DAT16(resp_OUT_DAT16),
    .OUT_XFC  (resp_OUT_XFC  )
);

endmodule