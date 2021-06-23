`timescale 1ns / 1ps

module FSM_tb;
    // declare logic variables from design
    logic clk;
    logic rst;
    logic in1;
    logic in2;
    logic [2:0] out;
    
    logic [31:0] i; // counter 
    
    // device under test
    FSM dut(
        .clk(clk),
        .rs(rst),
        .p1(in1),
        .p2(in2),
        .Y(out)
    );
    
    // vector to be read in from memory
    logic [2:0] testVector[1000:0];
    
    // initial read from memory
    initial
        begin
            $readmemb("tb_vector.mem", testVector);
            i = 0;
            rst = 1; in1 = 0; in2 = 0; // initialize with reset
        end
       
    // serve up new inputs every clock cycle
    always @(posedge clk)
        begin
            {rst, in1, in2} = testVector[i]; #10;
            $display(rst, in1, in2);
        end
     
    // increment memory index
    always @(negedge clk)
        begin
            i += 1;
        end
    
    // flip flop for clock cycling
    always
        begin
            clk <= 1; #5;
            clk <= 0; #5;
        end

endmodule
