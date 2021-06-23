`timescale 1ns / 1ps

`define WORDLENGTH          (8) // # of bits per element in FIFO storage
`define LOG2_DEPTH          (2) // total # of FIFO elements = 2^LOG2_DEPTH

`define TARGET_XFCS     (10000) // total # of elements to transfer in this test

`define TB_TX_ALWAYS_RDY    (0) // 0-do flow control at source, 1-testbench is always ready to send new data
`define TB_TX_RNDLOAD_EN    (0) // 0-incoming data flow rate is periodic, 1-incoming data flow rate is random
`define TB_TX_LOAD_PER     (10) // period between arrivals, for periodic incoming data model
`define TB_TX_DROP_PER    (100) // period where network dropouts are simulated
`define TB_TX_DROP_DUTY   ( 90) // within TB_TX_DROP_PER, #cycles dropped

`define TB_RX_ALWAYS_RDY    (0) // 0-do random flow control at sink, 1-testbench is always ready to receive new data
`define TB_RX_RNDLOAD_EN    (0) // 0-sink data flow rate is periodic, 1-sink data flow rate is random
`define TB_RX_LOAD_PER     (10) // period between departures, for periodic incoming data model
`define TB_RX_DROP_PER    ( 10) // period where sink dropouts are simulated
`define TB_RX_DROP_DUTY   (  1) // within TB_RX_DROP_PER, #cycles dropped

`define SIMPLE_STIM         (1) // 0-do stimulus with random data, 1-do stimulus with incrementing data

module tb ();

////////////////////////////////////////////////////////////////////////    
// Clock & reset generator
//
reg     clk;
reg     rst_ = 0;
wire    reset;

integer reset_count         = 0;
integer active_cycle_count  = 0;
integer xfc_count           = 0;
integer tx_drop_per_cnt     = 0;
integer rx_drop_per_cnt     = 0;

`define NUM_RESET_CYCLES (10)

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

wire                    stim_IN_RTS;
wire [`WORDLENGTH-1:0]  stim_IN_DAT;
wire                    stim_OUT_RTR;

wire                    resp_IN_RTR;
wire                    resp_OUT_RTS;
wire [`WORDLENGTH-1:0]  resp_OUT_DAT;

wire                    in_xfc;
wire                    out_xfc;

integer max_of_src_snk_per;
initial
begin
    if (`TB_TX_LOAD_PER > `TB_RX_LOAD_PER)
        max_of_src_snk_per = `TB_TX_LOAD_PER;
    else
        max_of_src_snk_per = `TB_RX_LOAD_PER;
end
    
assign  in_xfc =  stim_IN_RTS &  resp_IN_RTR;   // FIFO input transfer complete
assign out_xfc = resp_OUT_RTS & stim_OUT_RTR;   // FIFO output transfer complete

reg [`WORDLENGTH-1:0] in_dat_count;             // Count of data put into FIFO
reg [`WORDLENGTH-1:0] out_dat_count;            // Count of data gotten from FIFO
integer               pass_count = 0;

always @ (posedge clk)
begin
    if (rst_)
    begin
        active_cycle_count <= active_cycle_count + 1;  // Counts the total # of sim cycles after reset
        
        if (out_xfc)
            xfc_count <= xfc_count + 1;         // Count # of out_xfc's
            
        if (tx_drop_per_cnt == `TB_TX_DROP_PER-1)
            tx_drop_per_cnt  <= 0;
        else
            tx_drop_per_cnt <= tx_drop_per_cnt + 1;
        
        if (rx_drop_per_cnt == `TB_RX_DROP_PER-1)
            rx_drop_per_cnt  <= 0;
        else
            rx_drop_per_cnt <= rx_drop_per_cnt + 1;
        
        if (xfc_count == `TARGET_XFCS)          // End sim once all done
        begin
            // If we got to this point we passed verification test
            // Display the throughput in %, as ratio of data elements transferred over total # of cycles
            $display("*** PASS ***");
            $display("Correctly matched %6d elements", pass_count);
            $display("Efficiency = %6.2f%%", 100.0 * max_of_src_snk_per * $itor(xfc_count)/active_cycle_count);
            $finish;
        end
    end
end

reg                   src_ready;    // Source is ready to send
reg                   snk_ready;    // Sink is ready to receive
reg [`WORDLENGTH-1:0] stim_data[`TARGET_XFCS-1:0];

// The flow_control bit vector is used to control pacing data into
// and out from the FIFO using random number generation.
assign  stim_IN_RTS  = src_ready | `TB_TX_ALWAYS_RDY;
assign  stim_OUT_RTR = snk_ready | `TB_RX_ALWAYS_RDY;
assign  stim_IN_DAT  = stim_data[in_dat_count];

integer tmp;
always @ (posedge clk)
begin
    tmp    = $random();     // get a random number

    if (tx_drop_per_cnt >= `TB_TX_DROP_DUTY)
        if (`TB_TX_RNDLOAD_EN)
            src_ready <= tmp[0];
        else
            src_ready <= active_cycle_count > `TB_TX_LOAD_PER * in_dat_count;
    else
        src_ready <= 0;      // still in OFF part of dropout cycle
        
    if (rx_drop_per_cnt >= `TB_RX_DROP_DUTY)
        if (`TB_RX_RNDLOAD_EN)
            snk_ready <= tmp[1];
        else
            snk_ready <= active_cycle_count > `TB_RX_LOAD_PER * out_dat_count;
    else
        snk_ready <= 0;
end

integer i;
initial
begin
    for (i = 0; i < `TARGET_XFCS; i = i + 1)
        if (`SIMPLE_STIM)
            // Simple option: make the data an incrementing counter
            stim_data[i] = i;
        else
            // Complex option: make the data random
            stim_data[i] = $random();
end

always @ (posedge clk)
begin
    if (reset)
        in_dat_count    <= 0;   // Initialize count of data elements put to buffer
    else if (in_xfc)
        // Increment count of # of data elements put on 'input transfer complete'
        in_dat_count <= in_dat_count + 1;
end

always @ (posedge clk)
begin
    if (reset)
        out_dat_count <= 0; // Initialize count of data elements gotten from buffer
    else if (out_xfc)
    begin
        // Increment count of # of data elements gotten on 'output transfer complete'
        out_dat_count <= out_dat_count + 1;

        // Check FIFO output response data against stored value that was put into FIFO        
        if (stim_data[out_dat_count] == resp_OUT_DAT)
            pass_count <= pass_count + 1;
        else
        begin
            $display( "***** ----> FAIL on %08h, got %08h <---- ***** !!!\n", out_dat_count, resp_OUT_DAT );
            #25 $finish;
        end
    end
end

////////////////////////////////////////////////////////////////////////    
// Instantiate DUT
//

sp_fifo
#(  .WORDLENGTH(`WORDLENGTH),
    .LOG2_DEPTH(`LOG2_DEPTH)
)
u_sp_fifo
(
    .IN_RTS (stim_IN_RTS ),
    .IN_RTR (resp_IN_RTR ),
    .IN_DAT (stim_IN_DAT ),
    .OUT_RTS(resp_OUT_RTS),
    .OUT_RTR(stim_OUT_RTR),
    .OUT_DAT(resp_OUT_DAT),
    .clk    (clk         ),
    .reset  (reset       )
);

endmodule