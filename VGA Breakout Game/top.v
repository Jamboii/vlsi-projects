`timescale 1ns / 1ps

//`define REFRESH_MEM_MODE (1)

module top(
    input clk_in1,
    input rst_,
    output VGA_HS,
    output VGA_VS,
    output reg [3:0] VGA_R,
    output reg [3:0] VGA_G,
    output reg [3:0] VGA_B);
    
    wire enable_V_counter;
    wire [15:0] H_count_value;
    wire [15:0] V_count_value;
    reg reset;
    reg pre_reset;
    wire clk;
    wire locked;
    
    always @ (posedge clk)
    begin
        pre_reset <= ~rst_;
        reset <= pre_reset;
    end
    
    // values to use for simulation
    /*
    `define ACTIVE_Hend (63)
    `define FRONT_PORCH_Hend (65)
    `define SYNC_PULSE_Hend (75)
    `define BACKPORCH_Hend (79)
    
    `define ACTIVE_Vend (40)
    `define FRONT_PORCH_Vend (43)
    `define SYNC_PULSE_Vend (46)
    `define BACKPORCH_Vend (52)
    */
    
    `define ACTIVE_Hend (639)
    `define FRONT_PORCH_Hend (655)
    `define SYNC_PULSE_Hend (751)
    `define BACKPORCH_Hend (799)
    
    `define ACTIVE_Vend (479)
    `define FRONT_PORCH_Vend (489)
    `define SYNC_PULSE_Vend (491)
    `define BACKPORCH_Vend (520)
   
    horizontal_counter #(.BACKPORCH_Hend(`BACKPORCH_Hend)) vga_horiz(clk, reset, enable_V_counter, H_count_value);
    vertical_counter #(.BACKPORCH_Vend(`BACKPORCH_Vend)) vga_vert(clk, reset, enable_V_counter, V_count_value);
  
    //outputs
    assign VGA_HS = ~(H_count_value > `FRONT_PORCH_Hend && H_count_value <= `SYNC_PULSE_Hend) ? 1'b1:1'b0;
    assign VGA_VS = ~(V_count_value > `FRONT_PORCH_Vend && V_count_value <= `SYNC_PULSE_Vend) ? 1'b1:1'b0;
    
    //code for sprite animation, basically just animates a square around the screen
    reg [9:0] ball_length;
    reg [8:0] ball_height;
    reg [9:0] paddle_length;
    reg [8:0] paddle_height;
    reg [9:0] block_length;
    reg [8:0] block_height;
    reg [6:0] vx_mag; //x magnitude
    reg [6:0] vy_mag; //y magnitude
    reg ball_onscreen;
    reg gameO_onscreen;
    
    reg signed [9:0]  paddle_top; //y coord
    reg signed [10:0] paddle_left; //x coord
    reg signed [9:0]  ball_top; //y coord
    reg signed [10:0] ball_left; //x coord
    reg signed [9:0]  gameO_top; //y coord
    reg signed [10:0] gameO_left; //x coord
    
    reg signed [9:0]  BR0S0_top; //y coord
    reg signed [10:0] BR0S0_left; //x coord
    reg signed [9:0]  BR0S1_top; //y coord
    reg signed [10:0] BR0S1_left; //x coord
    reg signed [9:0]  BR0S2_top; //y coord
    reg signed [10:0] BR0S2_left;//x coord
    reg signed [9:0]  BR0S3_top; //y coord
    reg signed [10:0] BR0S3_left;//x coord
    reg signed [9:0]  BR0S4_top; //y coord
    reg signed [10:0] BR0S4_left; //x coord
    reg signed [9:0]  BR0S5_top; //y coord
    reg signed [10:0] BR0S5_left; //x coord
    reg signed [9:0]  BR0S6_top; //y coord
    reg signed [10:0] BR0S6_left; //x coord
    reg signed [9:0]  BR0S7_top; //y coord
    reg signed [10:0] BR0S7_left;//x coord
    reg signed [9:0]  BR0S8_top; //y coord
    reg signed [10:0] BR0S8_left; //x coord
    reg signed [9:0]  BR0S9_top; //y coord
    reg signed [10:0] BR0S9_left; //x coord
    reg signed [9:0]  BR0S10_top; //y coord
    reg signed [10:0] BR0S10_left; //x coord
    reg signed [9:0]  BR0S11_top; //y coord
    reg signed [10:0] BR0S11_left; //x coord
    reg signed [9:0]  BR0S12_top; //y coord
    reg signed [10:0] BR0S12_left;//x coord
    reg signed [9:0]  BR0S13_top; //y coord
    reg signed [10:0] BR0S13_left; //x coord
    reg signed [9:0]  BR0S14_top; //y coord
    reg signed [10:0] BR0S14_left; //x coord
    reg signed [9:0]  BR0S15_top; //y coord
    reg signed [10:0] BR0S15_left; //x coord
    
    reg signed [9:0]  BR1S0_top; //y coord
    reg signed [10:0] BR1S0_left; //x coord
    reg signed [9:0]  BR1S1_top; //y coord
    reg signed [10:0] BR1S1_left; //x coord
    reg signed [9:0]  BR1S2_top; //y coord
    reg signed [10:0] BR1S2_left;//x coord
    reg signed [9:0]  BR1S3_top; //y coord
    reg signed [10:0] BR1S3_left; //x coord
    reg signed [9:0]  BR1S4_top; //y coord
    reg signed [10:0] BR1S4_left; //x coord
    reg signed [9:0]  BR1S5_top; //y coord
    reg signed [10:0] BR1S5_left; //x coord
    reg signed [9:0]  BR1S6_top; //y coord
    reg signed [10:0] BR1S6_left; //x coord
    reg signed [9:0]  BR1S7_top; //y coord
    reg signed [10:0] BR1S7_left;//x coord
    reg signed [9:0]  BR1S8_top; //y coord
    reg signed [10:0] BR1S8_left; //x coord
    reg signed [9:0]  BR1S9_top; //y coord
    reg signed [10:0] BR1S9_left; //x coord
    reg signed [9:0]  BR1S10_top; //y coord
    reg signed [10:0] BR1S10_left; //x coord
    reg signed [9:0]  BR1S11_top; //y coord
    reg signed [10:0] BR1S11_left; //x coord
    reg signed [9:0]  BR1S12_top; //y coord
    reg signed [10:0] BR1S12_left;//x coord
    reg signed [9:0]  BR1S13_top; //y coord
    reg signed [10:0] BR1S13_left; //x coord
    reg signed [9:0]  BR1S14_top; //y coord
    reg signed [10:0] BR1S14_left; //x coord
    reg signed [9:0]  BR1S15_top; //y coord
    reg signed [10:0] BR1S15_left; //x coord
    
    reg signed [9:0]  BR2S0_top; //y coord
    reg signed [10:0] BR2S0_left; //x coord
    reg signed [9:0]  BR2S1_top; //y coord
    reg signed [10:0] BR2S1_left; //x coord
    reg signed [9:0]  BR2S2_top; //y coord
    reg signed [10:0] BR2S2_left;//x coord
    reg signed [9:0]  BR2S3_top; //y coord
    reg signed [10:0] BR2S3_left; //x coord
    reg signed [9:0]  BR2S4_top; //y coord
    reg signed [10:0] BR2S4_left; //x coord
    reg signed [9:0]  BR2S5_top; //y coord
    reg signed [10:0] BR2S5_left; //x coord
    reg signed [9:0]  BR2S6_top; //y coord
    reg signed [10:0] BR2S6_left; //x coord
    reg signed [9:0]  BR2S7_top; //y coord
    reg signed [10:0] BR2S7_left;//x coord
    reg signed [9:0]  BR2S8_top; //y coord
    reg signed [10:0] BR2S8_left; //x coord
    reg signed [9:0]  BR2S9_top; //y coord
    reg signed [10:0] BR2S9_left; //x coord
    reg signed [9:0]  BR2S10_top; //y coord
    reg signed [10:0] BR2S10_left; //x coord
    reg signed [9:0]  BR2S11_top; //y coord
    reg signed [10:0] BR2S11_left; //x coord
    reg signed [9:0]  BR2S12_top; //y coord
    reg signed [10:0] BR2S12_left;//x coord
    reg signed [9:0]  BR2S13_top; //y coord
    reg signed [10:0] BR2S13_left; //x coord
    reg signed [9:0]  BR2S14_top; //y coord
    reg signed [10:0] BR2S14_left; //x coord
    reg signed [9:0]  BR2S15_top; //y coord
    reg signed [10:0] BR2S15_left; //x coord
    
    reg signed [7:0] paddle_vx_dir; //actual x direction
    reg signed [7:0] paddle_vy_dir; //actual y direction
    reg signed [7:0] ball_vx_dir; //actual x direction
    reg signed [7:0] ball_vy_dir; //actual y direction
    
    reg [5:0] color;
    
    wire [3:0] paddle_red;
    wire [3:0] paddle_grn;
    wire [3:0] paddle_blu;
    wire paddle_vld;
    wire [3:0] ball_red;
    wire [3:0] ball_grn;
    wire [3:0] ball_blu;
    wire ball_vld;
    wire ball_vis;
    wire [3:0] gameO_red;
    wire [3:0] gameO_grn;
    wire [3:0] gameO_blu;
    wire gameO_vld;
    wire gameO_vis;
    
    wire [3:0] BR0S0_red; //block row 1 spot 0
    wire [3:0] BR0S0_grn;
    wire [3:0] BR0S0_blu;
    wire BR0S0_vld;
    reg BR0S0_vis;
    wire [3:0] BR0S1_red; //block row 1 spot 1
    wire [3:0] BR0S1_grn;
    wire [3:0] BR0S1_blu;
    wire BR0S1_vld;
    reg BR0S1_vis;
    wire [3:0] BR0S2_red; //block row 1 spot 2
    wire [3:0] BR0S2_grn;
    wire [3:0] BR0S2_blu;
    wire BR0S2_vld;
    reg BR0S2_vis;
    wire [3:0] BR0S3_red; //block row 1 spot 3
    wire [3:0] BR0S3_grn;
    wire [3:0] BR0S3_blu;
    wire BR0S3_vld;
    reg BR0S3_vis;
    wire [3:0] BR0S4_red; //block row 1 spot 4
    wire [3:0] BR0S4_grn;
    wire [3:0] BR0S4_blu;
    wire BR0S4_vld;
    reg BR0S4_vis;
    wire [3:0] BR0S5_red; //block row 1 spot 5
    wire [3:0] BR0S5_grn;
    wire [3:0] BR0S5_blu;
    wire BR0S5_vld;
    reg BR0S5_vis;
    wire [3:0] BR0S6_red; //block row 1 spot 6
    wire [3:0] BR0S6_grn;
    wire [3:0] BR0S6_blu;
    wire BR0S6_vld;
    reg BR0S6_vis;
    wire [3:0] BR0S7_red; //block row 1 spot 7
    wire [3:0] BR0S7_grn;
    wire [3:0] BR0S7_blu;
    wire BR0S7_vld;
    reg BR0S7_vis;
    wire [3:0] BR0S8_red; //block row 1 spot 8
    wire [3:0] BR0S8_grn;
    wire [3:0] BR0S8_blu;
    wire BR0S8_vld;
    reg BR0S8_vis;
    wire [3:0] BR0S9_red; //block row 1 spot 9
    wire [3:0] BR0S9_grn;
    wire [3:0] BR0S9_blu;
    wire BR0S9_vld;
    reg BR0S9_vis;
    wire [3:0] BR0S10_red; //block row 1 spot 10
    wire [3:0] BR0S10_grn;
    wire [3:0] BR0S10_blu;
    wire BR0S10_vld;
    reg BR0S10_vis;
    wire [3:0] BR0S11_red; //block row 1 spot 11
    wire [3:0] BR0S11_grn;
    wire [3:0] BR0S11_blu;
    wire BR0S11_vld;
    reg BR0S11_vis;
    wire [3:0] BR0S12_red; //block row 1 spot 12
    wire [3:0] BR0S12_grn;
    wire [3:0] BR0S12_blu;
    wire BR0S12_vld;
    reg BR0S12_vis;
    wire [3:0] BR0S13_red; //block row 1 spot 13
    wire [3:0] BR0S13_grn;
    wire [3:0] BR0S13_blu;
    wire BR0S13_vld;
    reg BR0S13_vis;
    wire [3:0] BR0S14_red; //block row 1 spot 14
    wire [3:0] BR0S14_grn;
    wire [3:0] BR0S14_blu;
    wire BR0S14_vld;
    reg BR0S14_vis;
    wire [3:0] BR0S15_red; //block row 1 spot 15
    wire [3:0] BR0S15_grn;
    wire [3:0] BR0S15_blu;
    wire BR0S15_vld; 
    reg BR0S15_vis;
    
    wire [3:0] BR1S0_red; //block row 1 spot 0
    wire [3:0] BR1S0_grn;
    wire [3:0] BR1S0_blu;
    wire BR1S0_vld;
    reg BR1S0_vis;
    wire [3:0] BR1S1_red; //block row 1 spot 1
    wire [3:0] BR1S1_grn;
    wire [3:0] BR1S1_blu;
    wire BR1S1_vld;
    reg BR1S1_vis;
    wire [3:0] BR1S2_red; //block row 1 spot 2
    wire [3:0] BR1S2_grn;
    wire [3:0] BR1S2_blu;
    wire BR1S2_vld;
    reg BR1S2_vis;
    wire [3:0] BR1S3_red; //block row 1 spot 3
    wire [3:0] BR1S3_grn;
    wire [3:0] BR1S3_blu;
    wire BR1S3_vld;
    reg BR1S3_vis;
    wire [3:0] BR1S4_red; //block row 1 spot 4
    wire [3:0] BR1S4_grn;
    wire [3:0] BR1S4_blu;
    wire BR1S4_vld;
    reg BR1S4_vis;
    wire [3:0] BR1S5_red; //block row 1 spot 5
    wire [3:0] BR1S5_grn;
    wire [3:0] BR1S5_blu;
    wire BR1S5_vld;
    reg BR1S5_vis;
    wire [3:0] BR1S6_red; //block row 1 spot 6
    wire [3:0] BR1S6_grn;
    wire [3:0] BR1S6_blu;
    wire BR1S6_vld;
    reg BR1S6_vis;
    wire [3:0] BR1S7_red; //block row 1 spot 7
    wire [3:0] BR1S7_grn;
    wire [3:0] BR1S7_blu;
    wire BR1S7_vld;
    reg BR1S7_vis;
    wire [3:0] BR1S8_red; //block row 1 spot 8
    wire [3:0] BR1S8_grn;
    wire [3:0] BR1S8_blu;
    wire BR1S8_vld;
    reg BR1S8_vis;
    wire [3:0] BR1S9_red; //block row 1 spot 9
    wire [3:0] BR1S9_grn;
    wire [3:0] BR1S9_blu;
    wire BR1S9_vld;
    reg BR1S9_vis;
    wire [3:0] BR1S10_red; //block row 1 spot 10
    wire [3:0] BR1S10_grn;
    wire [3:0] BR1S10_blu;
    wire BR1S10_vld;
    reg BR1S10_vis;
    wire [3:0] BR1S11_red; //block row 1 spot 11
    wire [3:0] BR1S11_grn;
    wire [3:0] BR1S11_blu;
    wire BR1S11_vld;
    reg BR1S11_vis;
    wire [3:0] BR1S12_red; //block row 1 spot 12
    wire [3:0] BR1S12_grn;
    wire [3:0] BR1S12_blu;
    wire BR1S12_vld;
    reg BR1S12_vis;
    wire [3:0] BR1S13_red; //block row 1 spot 13
    wire [3:0] BR1S13_grn;
    wire [3:0] BR1S13_blu;
    wire BR1S13_vld;
    reg BR1S13_vis;
    wire [3:0] BR1S14_red; //block row 1 spot 14
    wire [3:0] BR1S14_grn;
    wire [3:0] BR1S14_blu;
    wire BR1S14_vld;
    reg BR1S14_vis;
    wire [3:0] BR1S15_red; //block row 1 spot 15
    wire [3:0] BR1S15_grn;
    wire [3:0] BR1S15_blu;
    wire BR1S15_vld;
    reg BR1S15_vis;
    
    wire [3:0] BR2S0_red; //block row 2 spot 0
    wire [3:0] BR2S0_grn;
    wire [3:0] BR2S0_blu;
    wire BR2S0_vld;
    reg BR2S0_vis;
    wire [3:0] BR2S1_red; //block row 2 spot 1
    wire [3:0] BR2S1_grn;
    wire [3:0] BR2S1_blu;
    wire BR2S1_vld;
    reg BR2S1_vis;
    wire [3:0] BR2S2_red; //block row 2 spot 2
    wire [3:0] BR2S2_grn;
    wire [3:0] BR2S2_blu;
    wire BR2S2_vld;
    reg BR2S2_vis;
    wire [3:0] BR2S3_red; //block row 2 spot 3
    wire [3:0] BR2S3_grn;
    wire [3:0] BR2S3_blu;
    wire BR2S3_vld;
    reg BR2S3_vis;
    wire [3:0] BR2S4_red; //block row 2 spot 4
    wire [3:0] BR2S4_grn;
    wire [3:0] BR2S4_blu;
    wire BR2S4_vld;
    reg BR2S4_vis;
    wire [3:0] BR2S5_red; //block row 2 spot 5
    wire [3:0] BR2S5_grn;
    wire [3:0] BR2S5_blu;
    wire BR2S5_vld;
    reg BR2S5_vis;
    wire [3:0] BR2S6_red; //block row 2 spot 6
    wire [3:0] BR2S6_grn;
    wire [3:0] BR2S6_blu;
    wire BR2S6_vld;
    reg BR2S6_vis;
    wire [3:0] BR2S7_red; //block row 2 spot 7
    wire [3:0] BR2S7_grn;
    wire [3:0] BR2S7_blu;
    wire BR2S7_vld;
    reg BR2S7_vis;
    wire [3:0] BR2S8_red; //block row 2 spot 8
    wire [3:0] BR2S8_grn;
    wire [3:0] BR2S8_blu;
    wire BR2S8_vld;
    reg BR2S8_vis;
    wire [3:0] BR2S9_red; //block row 2 spot 9
    wire [3:0] BR2S9_grn;
    wire [3:0] BR2S9_blu;
    wire BR2S9_vld;
    reg BR2S9_vis;
    wire [3:0] BR2S10_red; //block row 2 spot 10
    wire [3:0] BR2S10_grn;
    wire [3:0] BR2S10_blu;
    wire BR2S10_vld;
    reg BR2S10_vis;
    wire [3:0] BR2S11_red; //block row 2 spot 11
    wire [3:0] BR2S11_grn;
    wire [3:0] BR2S11_blu;
    wire BR2S11_vld;
    reg BR2S11_vis;
    wire [3:0] BR2S12_red; //block row 2 spot 12
    wire [3:0] BR2S12_grn;
    wire [3:0] BR2S12_blu;
    wire BR2S12_vld;
    reg BR2S12_vis;
    wire [3:0] BR2S13_red; //block row 2 spot 13
    wire [3:0] BR2S13_grn;
    wire [3:0] BR2S13_blu;
    wire BR2S13_vld;
    reg BR2S13_vis;
    wire [3:0] BR2S14_red; //block row 2 spot 14
    wire [3:0] BR2S14_grn;
    wire [3:0] BR2S14_blu;
    wire BR2S14_vld;
    reg BR2S14_vis;
    wire [3:0] BR2S15_red; //block row 2 spot 15
    wire [3:0] BR2S15_grn;
    wire [3:0] BR2S15_blu;
    wire BR2S15_vld;
    reg BR2S15_vis;
    
    `ifndef REFRESH_MEM_MODE
    
    // Sprite animation mode
    always @ (posedge clk)
     begin
         if(reset)
         begin
             ball_length <= 20;
             ball_height <= 20;
             paddle_length <= 120;
             paddle_height <= 40;
                 block_length <= 40;
             block_height <= 40;
             ball_onscreen <= 1'b1;
             gameO_onscreen <= 1'b0;
             vx_mag <= 5;
             vy_mag <= 5;
             paddle_vx_dir <= -vx_mag; 
             paddle_vy_dir <= 0; 
             ball_vx_dir <= vx_mag; 
             ball_vy_dir <= vy_mag; 
         end
         else if (H_count_value == 0 && V_count_value == 0)
         begin             
             // border collision detection
             if(ball_left <= $signed(11'h0)) begin                        // left border
                 ball_vx_dir <= vx_mag;
             end else if((ball_left + ball_length) >= `ACTIVE_Hend) begin // right border
                 ball_vx_dir <= -vx_mag;
             end
             if(ball_top <= $signed(10'h0)) begin                         // top border
                 ball_vy_dir <= vy_mag;
             end else if((ball_top + ball_height) >= `ACTIVE_Vend) begin  // bottom border
                 ball_vy_dir <= -vy_mag;
             end
             
             // paddle collision detection
             if ((ball_top + ball_height) >= paddle_top) begin // check if ball is in same y region
                 if (ball_left >= paddle_left && (ball_left + ball_length) <= (paddle_left + paddle_length)) begin // check if the ball is between the x region of the paddle
                     ball_vy_dir <= -vy_mag;
                 end
             end
             
             // block collision detection
             // Logic for collision of ROW3
             // Is the top of the ball intersecting with the bottom pixel of the 3rd row
             if (ball_top <= BR2S0_top + block_height && ball_top >= BR2S0_top + block_height - 5 && ball_vy_dir < 0) begin
                 // Logic for collision of BR2S0
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 if (ball_left + ball_length >= BR2S0_left && ball_left + ball_length < BR2S0_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR2S0_vis == 1) begin
                         // invert velocity of ball
                         ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR2S1
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR2S1_left && ball_left + ball_length < BR2S1_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR2S1_vis == 1) begin
                         // invert velocity of ball
                         ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR2S2
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR2S2_left && ball_left + ball_length < BR2S2_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR2S2_vis == 1) begin
                         // invert velocity of ball
                         ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR2S3
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR2S3_left && ball_left + ball_length < BR2S3_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR2S3_vis == 1) begin
                         // invert velocity of ball
                         ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR2S4
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR2S4_left && ball_left + ball_length < BR2S4_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR2S4_vis == 1) begin
                         // invert velocity of ball
                         ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR2S5
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR2S5_left && ball_left + ball_length < BR2S5_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR2S5_vis == 1) begin
                         // invert velocity of ball
                         ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR2S6
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR2S6_left && ball_left + ball_length < BR2S6_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR2S6_vis == 1) begin
                         // invert velocity of ball
                         ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR2S7
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR2S7_left && ball_left + ball_length < BR2S7_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR2S7_vis == 1) begin
                         // invert velocity of ball
                         ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR2S8
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR2S8_left && ball_left + ball_length < BR2S8_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR2S8_vis == 1) begin
                         // invert velocity of ball
                         ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR2S9
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR2S9_left && ball_left + ball_length < BR2S9_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR2S9_vis == 1) begin
                         // invert velocity of ball
                         ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR2S10
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR2S10_left && ball_left + ball_length < BR2S10_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR2S10_vis == 1) begin
                         // invert velocity of ball
                         ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR2S11
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR2S11_left && ball_left + ball_length < BR2S11_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR2S11_vis == 1) begin
                         // invert velocity of ball
                         ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR2S12
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR2S12_left && ball_left + ball_length < BR2S12_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR2S12_vis == 1) begin
                         // invert velocity of ball
                         ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR2S13
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR2S13_left && ball_left + ball_length < BR2S13_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR2S13_vis == 1) begin
                         // invert velocity of ball
                         ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR2S14
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR2S14_left && ball_left + ball_length < BR2S14_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR2S14_vis == 1) begin
                         // invert velocity of ball
                         ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR2S15
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR2S15_left && ball_left + ball_length < BR2S15_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR2S15_vis == 1) begin
                         // invert velocity of ball
                         ball_vy_dir <= vy_mag;
                     end       
                 end
             end
                 
             //
             // Block collision for ROW 2
             //
             else if (ball_top <= BR1S0_top + block_height && ball_top >= BR1S0_top + block_height - 5 && ball_vy_dir < 0) begin
             // Logic for collision of BR1S0
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 if (ball_left + ball_length >= BR1S0_left && ball_left + ball_length < BR1S0_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR1S0_vis == 1) begin
                        // invert velocity of ball
                        ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR1S1
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR1S1_left && ball_left + ball_length < BR1S1_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR1S1_vis == 1) begin
                         // invert velocity of ball
                        ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR1S2
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR1S2_left && ball_left + ball_length < BR1S2_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR1S2_vis == 1) begin
                         // invert velocity of ball
                        ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR1S3
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR1S3_left && ball_left + ball_length < BR1S3_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR1S3_vis == 1) begin
                         // invert velocity of ball
                         ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR1S4
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR1S4_left && ball_left + ball_length < BR1S4_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR1S4_vis == 1) begin
                         // invert velocity of ball
                        ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR1S5
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR1S5_left && ball_left + ball_length < BR1S5_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR1S5_vis == 1) begin
                         // invert velocity of ball
                        ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR1S6
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR1S6_left && ball_left + ball_length < BR1S6_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR1S6_vis == 1) begin
                         // invert velocity of ball
                         ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR1S7
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR1S7_left && ball_left + ball_length < BR1S7_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR1S7_vis == 1) begin
                         // invert velocity of ball
                        ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR1S8
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR1S8_left && ball_left + ball_length < BR1S8_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR1S8_vis == 1) begin
                         // invert velocity of ball
                        ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR1S9
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR1S9_left && ball_left + ball_length < BR1S9_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR1S9_vis == 1) begin
                         // invert velocity of ball
                        ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR1S10
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR1S10_left && ball_left + ball_length < BR1S10_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR1S10_vis == 1) begin
                         // invert velocity of ball
                        ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR1S11
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR1S11_left && ball_left + ball_length < BR1S11_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR1S11_vis == 1) begin
                         // invert velocity of ball
                        ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR1S12
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR1S12_left && ball_left + ball_length < BR1S12_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR1S12_vis == 1) begin
                         // invert velocity of ball
                        ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR1S13
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR1S13_left && ball_left + ball_length < BR1S13_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR1S13_vis == 1) begin
                         // invert velocity of ball
                        ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR1S14
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR1S14_left && ball_left + ball_length < BR1S14_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR1S14_vis == 1) begin
                         // invert velocity of ball
                        ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR1S15
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR1S15_left && ball_left + ball_length < BR1S15_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR1S15_vis == 1) begin
                         // invert velocity of ball
                        ball_vy_dir <= vy_mag;
                     end       
                 end
             end
                     
             //
             // Block collision for ROW 1
             //
             else if (ball_top <= BR0S0_top + block_height && ball_top >= BR0S0_top + block_height - 5 && ball_vy_dir < 0) begin     
                 // Logic for collision of BR0S0
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 if (ball_left + ball_length >= BR0S0_left && ball_left + ball_length < BR0S0_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR0S0_vis == 1) begin
                         // invert velocity of ball
                        ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR0S1
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR0S1_left && ball_left + ball_length < BR0S1_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR0S1_vis == 1) begin
                         // invert velocity of ball
                        ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR0S2
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR0S2_left && ball_left + ball_length < BR0S2_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR0S2_vis == 1) begin
                         // invert velocity of ball
                        ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR0S3
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR0S3_left && ball_left + ball_length < BR0S3_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR0S3_vis == 1) begin
                         // invert velocity of ball
                        ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR0S4
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR0S4_left && ball_left + ball_length < BR0S4_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR0S4_vis == 1) begin
                         // invert velocity of ball
                        ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR0S5
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR0S5_left && ball_left + ball_length < BR0S5_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR0S5_vis == 1) begin
                        // invert velocity of ball
                        ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR0S6
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR0S6_left && ball_left + ball_length < BR0S6_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR0S6_vis == 1) begin
                         // invert velocity of ball
                        ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR0S7
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR0S7_left && ball_left + ball_length < BR0S7_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR0S7_vis == 1) begin
                         // invert velocity of ball
                        ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR0S8
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR0S8_left && ball_left + ball_length < BR0S8_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR0S8_vis == 1) begin
                        // invert velocity of ball
                        ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR0S9
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR0S9_left && ball_left + ball_length < BR0S9_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR0S9_vis == 1) begin
                         // invert velocity of ball
                        ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR0S10
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR0S10_left && ball_left + ball_length < BR0S10_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR0S10_vis == 1) begin
                         // invert velocity of ball
                         ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR0S11
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR0S11_left && ball_left + ball_length < BR0S11_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR0S11_vis == 1) begin
                         // invert velocity of ball
                         ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR0S12
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR0S12_left && ball_left + ball_length < BR0S12_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR0S12_vis == 1) begin
                         // then kill the visibility of the block
                         ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR0S13
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR0S13_left && ball_left + ball_length < BR0S13_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR0S13_vis == 1) begin
                         // invert velocity of ball
                         ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR0S14
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR0S14_left && ball_left + ball_length < BR0S14_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR0S14_vis == 1) begin
                         // invert velocity of ball
                        ball_vy_dir <= vy_mag;
                     end       
                 end
                 // Logic for collision of BR0S15
                 // if top middle of ball is intersecting with bottom of block AND that block is visible
                 else if (ball_left + ball_length >= BR0S15_left && ball_left + ball_length < BR0S15_left + block_length + ball_length) begin
                     // block is visible AND if ball has negative y velocity, indicating that it is going UP
                     if (BR0S15_vis == 1) begin
                         // invert velocity of ball
                        ball_vy_dir <= vy_mag;
                     end       
                 end
             end
         end
     end

     // Block to assign initial sprite positions
     always @ (posedge clk)
     begin
         if(reset)
         begin
             paddle_top <= 440;
             paddle_left <= 200;
             ball_top <= 240;
             ball_left <= 200;
             // 640 x 480 , position at center
             gameO_top <= 240 - 80;
             gameO_left <= 320 - 107;
             
             BR0S0_top <= 0;
             BR0S0_left <= 0;
             BR0S1_top <= 0;
             BR0S1_left <= 40;
             BR0S2_top <= 0;
             BR0S2_left <= 80;
             BR0S3_top <= 0;
             BR0S3_left <= 120;
             BR0S4_top <= 0;
             BR0S4_left <= 160;
             BR0S5_top <= 0;
             BR0S5_left <= 200;
             BR0S6_top <= 0;
             BR0S6_left <= 240;
             BR0S7_top <= 0;
             BR0S7_left <= 280;
             BR0S8_top <= 0;
             BR0S8_left <= 320;
             BR0S9_top <= 0;
             BR0S9_left <= 360;
             BR0S10_top <= 0;
             BR0S10_left <= 400;
             BR0S11_top <= 0;
             BR0S11_left <= 440;
             BR0S12_top <= 0;
             BR0S12_left <= 480;
             BR0S13_top <= 0;
             BR0S13_left <= 520;
             BR0S14_top <= 0;
             BR0S14_left <= 560;
             BR0S15_top <= 0;
             BR0S15_left <= 600;
             
             BR1S0_top <= 40;
             BR1S0_left <= 0;
             BR1S1_top <= 40;
             BR1S1_left <= 40;
             BR1S2_top <= 40;
             BR1S2_left <= 80;
             BR1S3_top <= 40;
             BR1S3_left <= 120;
             BR1S4_top <= 40;
             BR1S4_left <= 160;
             BR1S5_top <= 40;
             BR1S5_left <= 200;
             BR1S6_top <= 40;
             BR1S6_left <= 240;
             BR1S7_top <= 40;
             BR1S7_left <= 280;
             BR1S8_top <= 40;
             BR1S8_left <= 320;
             BR1S9_top <= 40;
             BR1S9_left <= 360;
             BR1S10_top <= 40;
             BR1S10_left <= 400;
             BR1S11_top <= 40;
             BR1S11_left <= 440;
             BR1S12_top <= 40;
             BR1S12_left <= 480;
             BR1S13_top <= 40;
             BR1S13_left <= 520;
             BR1S14_top <= 40;
             BR1S14_left <= 560;
             BR1S15_top <= 40;
             BR1S15_left <= 600;
            
             BR2S0_top <= 80;
             BR2S0_left <= 0;
             BR2S1_top <= 80;
             BR2S1_left <= 40;
             BR2S2_top <= 80;
             BR2S2_left <= 80;
             BR2S3_top <= 80;
             BR2S3_left <= 120;
             BR2S4_top <= 80;
             BR2S4_left <= 160;
             BR2S5_top <= 80;
             BR2S5_left <= 200;
             BR2S6_top <= 80;
             BR2S6_left <= 240;
             BR2S7_top <= 80;
             BR2S7_left <= 280;
             BR2S8_top <= 80;
             BR2S8_left <= 320;
             BR2S9_top <= 80;
             BR2S9_left <= 360;
             BR2S10_top <= 80;
             BR2S10_left <= 400;
             BR2S11_top <= 80;
             BR2S11_left <= 440;
             BR2S12_top <= 80;
             BR2S12_left <= 480;
             BR2S13_top <= 80;
             BR2S13_left <= 520;
             BR2S14_top <= 80;
             BR2S14_left <= 560;
             BR2S15_top <= 80;
             BR2S15_left <= 600;
         end
         else
         begin // updating the position of the moving objects
             if(H_count_value == 0 && V_count_value == 0)
             begin
                 
                 ball_top <= ball_top + ball_vy_dir;    // y direction
                 ball_left <= ball_left + ball_vx_dir;  // x direction       
                 
                 // Logic to move paddle
                 // if ball is in pos that allows paddle to move
                 if (ball_left > $signed(11'h0) + ($signed(paddle_length / 2) - $signed(ball_length / 2)) && (ball_left + ball_length) < `ACTIVE_Hend - ((paddle_length / 2) - (ball_length / 2))) begin
                     // move paddle so it is always tracking the center of the ball
                     paddle_left <= ball_left - ((paddle_length / 2) - (ball_length / 2));
                 end
                                  
                 // TODO no idea if this logic is necessary
                 if(ball_left <= $signed(11'h0)) begin                        // left border
                     ball_left <= ball_left + ball_vx_dir;
                 end else if((ball_left + ball_length) >= `ACTIVE_Hend) begin // right border
                     ball_left <= ball_left + ball_vx_dir;
                 end

                 if(ball_top <= $signed(10'h0)) begin                         // top border
                     ball_top <= ball_top + ball_vy_dir;
                 end else if((ball_top + ball_height) >= `ACTIVE_Vend) begin  // bottom border
                     ball_top <= ball_top + ball_vy_dir;
                 end
             end
         end
     end
     
     // Block to assign visibility of breakout blocks based on ball collision
     always @ (posedge clk) 
     begin
         if (reset)
         begin
             // ROW 3
             BR2S0_vis <= 1;
             BR2S1_vis <= 1;
             BR2S2_vis <= 1;
             BR2S3_vis <= 1;
             BR2S4_vis <= 1;
             BR2S5_vis <= 1;
             BR2S6_vis <= 1;
             BR2S7_vis <= 1;
             BR2S8_vis <= 1;
             BR2S9_vis <= 1;
             BR2S10_vis <= 1;
             BR2S11_vis <= 1;
             BR2S12_vis <= 1;
             BR2S13_vis <= 1;
             BR2S14_vis <= 1;
             BR2S15_vis <= 1;
             
             // ROW 2
             BR1S0_vis <= 1;
             BR1S1_vis <= 1;
             BR1S2_vis <= 1;
             BR1S3_vis <= 1;
             BR1S4_vis <= 1;
             BR1S5_vis <= 1;
             BR1S6_vis <= 1;
             BR1S7_vis <= 1;
             BR1S8_vis <= 1;
             BR1S9_vis <= 1;
             BR1S10_vis <= 1;
             BR1S11_vis <= 1;
             BR1S12_vis <= 1;
             BR1S13_vis <= 1;
             BR1S14_vis <= 1;
             BR1S15_vis <= 1;
             
             // ROW 1
             BR0S0_vis <= 1;
             BR0S1_vis <= 1;
             BR0S2_vis <= 1;
             BR0S3_vis <= 1;
             BR0S4_vis <= 1;
             BR0S5_vis <= 1;
             BR0S6_vis <= 1;
             BR0S7_vis <= 1;
             BR0S8_vis <= 1;
             BR0S9_vis <= 1;
             BR0S10_vis <= 1;
             BR0S11_vis <= 1;
             BR0S12_vis <= 1;
             BR0S13_vis <= 1;
             BR0S14_vis <= 1;
             BR0S15_vis <= 1;
         end
         else
         begin
             if (H_count_value == 0 && V_count_value == 0)
             begin
                 // Logic for collision of ROW 3
                 // is the top of the ball intersecting with the bottom pixel of the 3rd row?
                 if (ball_top <= BR2S0_top + block_height && ball_top >= BR2S0_top + block_height - 5 && ball_vy_dir < 0) begin
                     // Logic for collision of BR2S0
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     if (ball_left + ball_length >= BR2S0_left && ball_left + ball_length < BR2S0_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR2S0_vis == 1) begin
                             // then kill the visibility of the block
                             BR2S0_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR2S1
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR2S1_left && ball_left + ball_length < BR2S1_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR2S1_vis == 1) begin
                             // then kill the visibility of the block
                             BR2S1_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR2S2
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR2S2_left && ball_left + ball_length < BR2S2_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR2S2_vis == 1) begin
                             // then kill the visibility of the block
                             BR2S2_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR2S3
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR2S3_left && ball_left + ball_length < BR2S3_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR2S3_vis == 1) begin
                             // then kill the visibility of the block
                             BR2S3_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR2S4
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR2S4_left && ball_left + ball_length < BR2S4_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR2S4_vis == 1) begin
                             // then kill the visibility of the block
                             BR2S4_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR2S5
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR2S5_left && ball_left + ball_length < BR2S5_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR2S5_vis == 1) begin
                             // then kill the visibility of the block
                             BR2S5_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR2S6
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR2S6_left && ball_left + ball_length < BR2S6_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR2S6_vis == 1) begin
                             // then kill the visibility of the block
                             BR2S6_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR2S7
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR2S7_left && ball_left + ball_length < BR2S7_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR2S7_vis == 1) begin
                             // then kill the visibility of the block
                             BR2S7_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR2S8
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR2S8_left && ball_left + ball_length < BR2S8_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR2S8_vis == 1) begin
                             // then kill the visibility of the block
                             BR2S8_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR2S9
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR2S9_left && ball_left + ball_length < BR2S9_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR2S9_vis == 1) begin
                             // then kill the visibility of the block
                             BR2S9_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR2S10
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR2S10_left && ball_left + ball_length < BR2S10_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR2S10_vis == 1) begin
                             // then kill the visibility of the block
                             BR2S10_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR2S11
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR2S11_left && ball_left + ball_length < BR2S11_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR2S11_vis == 1) begin
                             // then kill the visibility of the block
                             BR2S11_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR2S12
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR2S12_left && ball_left + ball_length < BR2S12_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR2S12_vis == 1) begin
                             // then kill the visibility of the block
                             BR2S12_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR2S13
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR2S13_left && ball_left + ball_length < BR2S13_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR2S13_vis == 1) begin
                             // then kill the visibility of the block
                             BR2S13_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR2S14
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR2S14_left && ball_left + ball_length < BR2S14_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR2S14_vis == 1) begin
                             // then kill the visibility of the block
                             BR2S14_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR2S15
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR2S15_left && ball_left + ball_length < BR2S15_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR2S15_vis == 1) begin
                             // then kill the visibility of the block
                             BR2S15_vis <= 0;
                         end       
                     end
                 end
                   
                 //
                 // ROW 1
                 //  
                 else if (ball_top <= BR1S0_top + block_height && ball_top >= BR1S0_top + block_height - 5 && ball_vy_dir < 0) begin
                     // Logic for collision of BR1S0
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     if (ball_left + ball_length >= BR1S0_left && ball_left + ball_length < BR1S0_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR1S0_vis == 1) begin
                             // then kill the visibility of the block
                             BR1S0_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR1S1
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR1S1_left && ball_left + ball_length < BR1S1_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR1S1_vis == 1) begin
                             // then kill the visibility of the block
                             BR1S1_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR1S2
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR1S2_left && ball_left + ball_length < BR1S2_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR1S2_vis == 1) begin
                             // then kill the visibility of the block
                             BR1S2_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR1S3
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR1S3_left && ball_left + ball_length < BR1S3_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR1S3_vis == 1) begin
                             // then kill the visibility of the block
                             BR1S3_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR1S4
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR1S4_left && ball_left + ball_length < BR1S4_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR1S4_vis == 1) begin
                             // then kill the visibility of the block
                             BR1S4_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR1S5
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR1S5_left && ball_left + ball_length < BR1S5_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR1S5_vis == 1) begin
                             // then kill the visibility of the block
                             BR1S5_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR1S6
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR1S6_left && ball_left + ball_length < BR1S6_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR1S6_vis == 1) begin
                             // then kill the visibility of the block
                             BR1S6_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR1S7
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR1S7_left && ball_left + ball_length < BR1S7_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR1S7_vis == 1) begin
                             // then kill the visibility of the block
                             BR1S7_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR1S8
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR1S8_left && ball_left + ball_length < BR1S8_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR1S8_vis == 1) begin
                             // then kill the visibility of the block
                             BR1S8_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR1S9
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR1S9_left && ball_left + ball_length < BR1S9_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR1S9_vis == 1) begin
                             // then kill the visibility of the block
                             BR1S9_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR1S10
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR1S10_left && ball_left + ball_length < BR1S10_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR1S10_vis == 1) begin
                             // then kill the visibility of the block
                             BR1S10_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR1S11
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR1S11_left && ball_left + ball_length < BR1S11_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR1S11_vis == 1) begin
                             // then kill the visibility of the block
                             BR1S11_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR1S12
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR1S12_left && ball_left + ball_length < BR1S12_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR1S12_vis == 1) begin
                             // then kill the visibility of the block
                             BR1S12_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR1S13
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR1S13_left && ball_left + ball_length < BR1S13_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR1S13_vis == 1) begin
                             // then kill the visibility of the block
                             BR1S13_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR1S14
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR1S14_left && ball_left + ball_length < BR1S14_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR1S14_vis == 1) begin
                             // then kill the visibility of the block
                             BR1S14_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR1S15
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR1S15_left && ball_left + ball_length < BR1S15_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR1S15_vis == 1) begin
                             // then kill the visibility of the block
                             BR1S15_vis <= 0;
                         end       
                     end
                 end
                    
                 //
                 // ROW 1
                 // 
                 else if (ball_top <= BR0S0_top + block_height && ball_top >= BR0S0_top + block_height - 5 && ball_vy_dir < 0) begin     
                     // Logic for collision of BR0S0
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     if (ball_left + ball_length >= BR0S0_left && ball_left + ball_length < BR0S0_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR0S0_vis == 1) begin
                             // then kill the visibility of the block
                             BR0S0_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR0S1
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR0S1_left && ball_left + ball_length < BR0S1_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR0S1_vis == 1) begin
                             // then kill the visibility of the block
                             BR0S1_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR0S2
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR0S2_left && ball_left + ball_length < BR0S2_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR0S2_vis == 1) begin
                             // then kill the visibility of the block
                             BR0S2_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR0S3
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR0S3_left && ball_left + ball_length < BR0S3_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR0S3_vis == 1) begin
                             // then kill the visibility of the block
                             BR0S3_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR0S4
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR0S4_left && ball_left + ball_length < BR0S4_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR0S4_vis == 1) begin
                             // then kill the visibility of the block
                             BR0S4_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR0S5
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR0S5_left && ball_left + ball_length < BR0S5_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR0S5_vis == 1) begin
                             // then kill the visibility of the block
                             BR0S5_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR0S6
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR0S6_left && ball_left + ball_length < BR0S6_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR0S6_vis == 1) begin
                             // then kill the visibility of the block
                             BR0S6_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR0S7
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR0S7_left && ball_left + ball_length < BR0S7_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR0S7_vis == 1) begin
                             // then kill the visibility of the block
                             BR0S7_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR0S8
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR0S8_left && ball_left + ball_length < BR0S8_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR0S8_vis == 1) begin
                             // then kill the visibility of the block
                             BR0S8_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR0S9
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR0S9_left && ball_left + ball_length < BR0S9_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR0S9_vis == 1) begin
                             // then kill the visibility of the block
                             BR0S9_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR0S10
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR0S10_left && ball_left + ball_length < BR0S10_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR0S10_vis == 1) begin
                             // then kill the visibility of the block
                             BR0S10_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR0S11
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR0S11_left && ball_left + ball_length < BR0S11_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR0S11_vis == 1) begin
                             // then kill the visibility of the block
                             BR0S11_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR0S12
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR0S12_left && ball_left + ball_length < BR0S12_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR0S12_vis == 1) begin
                             // then kill the visibility of the block
                             BR0S12_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR0S13
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR0S13_left && ball_left + ball_length < BR0S13_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR0S13_vis == 1) begin
                             // then kill the visibility of the block
                             BR0S13_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR0S14
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR0S14_left && ball_left + ball_length < BR0S14_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR0S14_vis == 1) begin
                             // then kill the visibility of the block
                             BR0S14_vis <= 0;
                         end       
                     end
                     // Logic for collision of BR0S15
                     // if top middle of ball is intersecting with bottom of block AND that block is visible
                     else if (ball_left + ball_length >= BR0S15_left && ball_left + ball_length < BR0S15_left + block_length + ball_length) begin
                         // block is visible AND if ball has negative y velocity, indicating that it is going UP
                         if (BR0S15_vis == 1) begin
                             // then kill the visibility of the block
                             BR0S15_vis <= 0;
                         end       
                     end
                 end
             end
         end
     end
 
 sprite #( .spriteType(9) ) paddle(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(paddle_left ),
    .SPRITE_ORIGIN_OFFSET_Y(paddle_top  ),
    .VISIBLE               (1'b1         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (paddle_red  ),
    .GRN                   (paddle_grn  ),
    .BLU                   (paddle_blu  ),
    .VALID                 (paddle_vld  ) );
    
 sprite #( .spriteType(8) ) ball(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(ball_left ),
    .SPRITE_ORIGIN_OFFSET_Y(ball_top  ),
    .VISIBLE               (1'b1         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (ball_red  ),
    .GRN                   (ball_grn  ),
    .BLU                   (ball_blu  ),
    .VALID                 (ball_vld  ) );
    
/*
 sprite #( .spriteType(10) ) gameO(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(gameO_left ),
    .SPRITE_ORIGIN_OFFSET_Y(gameO_top  ),
    .VISIBLE               (1'b1        ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (gameO_red  ),
    .GRN                   (gameO_grn  ),
    .BLU                   (gameO_blu  ),
    .VALID                 (gameO_vld  ) );
*/
    
 // ROW 1
 sprite #( .spriteType(2) ) BR0S0(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR0S0_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR0S0_top  ),
    .VISIBLE               (BR0S0_vis        ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR0S0_red  ),
    .GRN                   (BR0S0_grn  ),
    .BLU                   (BR0S0_blu  ),
    .VALID                 (BR0S0_vld  ) );
 sprite #( .spriteType(6) ) BR0S1(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR0S1_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR0S1_top  ),
    .VISIBLE               (BR0S1_vis        ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR0S1_red  ),
    .GRN                   (BR0S1_grn  ),
    .BLU                   (BR0S1_blu  ),
    .VALID                 (BR0S1_vld  ) );
sprite #( .spriteType(1) ) BR0S2(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR0S2_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR0S2_top  ),
    .VISIBLE               (BR0S2_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR0S2_red  ),
    .GRN                   (BR0S2_grn  ),
    .BLU                   (BR0S2_blu  ),
    .VALID                 (BR0S2_vld  ) );
 sprite #( .spriteType(3) ) BR0S3(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR0S3_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR0S3_top  ),
    .VISIBLE               (BR0S3_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR0S3_red  ),
    .GRN                   (BR0S3_grn  ),
    .BLU                   (BR0S3_blu  ),
    .VALID                 (BR0S3_vld  ) );
 sprite #( .spriteType(4) ) BR0S4(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR0S4_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR0S4_top  ),
    .VISIBLE               (BR0S4_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR0S4_red  ),
    .GRN                   (BR0S4_grn  ),
    .BLU                   (BR0S4_blu  ),
    .VALID                 (BR0S4_vld  ) );
 sprite #( .spriteType(1) ) BR0S5(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR0S5_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR0S5_top  ),
    .VISIBLE               (BR0S5_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR0S5_red  ),
    .GRN                   (BR0S5_grn  ),
    .BLU                   (BR0S5_blu  ),
    .VALID                 (BR0S5_vld  ) );
sprite #( .spriteType(5) ) BR0S6(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR0S6_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR0S6_top  ),
    .VISIBLE               (BR0S6_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR0S6_red  ),
    .GRN                   (BR0S6_grn  ),
    .BLU                   (BR0S6_blu  ),
    .VALID                 (BR0S6_vld  ) );
 sprite #( .spriteType(7) ) BR0S7(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR0S7_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR0S7_top  ),
    .VISIBLE               (BR0S7_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR0S7_red  ),
    .GRN                   (BR0S7_grn  ),
    .BLU                   (BR0S7_blu  ),
    .VALID                 (BR0S7_vld  ) );
 sprite #( .spriteType(2) ) BR0S8(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR0S8_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR0S8_top  ),
    .VISIBLE               (BR0S8_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR0S8_red  ),
    .GRN                   (BR0S8_grn  ),
    .BLU                   (BR0S8_blu  ),
    .VALID                 (BR0S8_vld  ) );
 sprite #( .spriteType(6) ) BR0S9(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR0S9_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR0S9_top  ),
    .VISIBLE               (BR0S9_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR0S9_red  ),
    .GRN                   (BR0S9_grn  ),
    .BLU                   (BR0S9_blu  ),
    .VALID                 (BR0S9_vld  ) );
sprite #( .spriteType(1) ) BR0S10(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR0S10_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR0S10_top  ),
    .VISIBLE               (BR0S10_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR0S10_red  ),
    .GRN                   (BR0S10_grn  ),
    .BLU                   (BR0S10_blu  ),
    .VALID                 (BR0S10_vld  ) );
 sprite #( .spriteType(3) ) BR0S11(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR0S11_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR0S11_top  ),
    .VISIBLE               (BR0S11_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR0S11_red  ),
    .GRN                   (BR0S11_grn  ),
    .BLU                   (BR0S11_blu  ),
    .VALID                 (BR0S11_vld  ) );
 sprite #( .spriteType(4) ) BR0S12(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR0S12_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR0S12_top  ),
    .VISIBLE               (BR0S12_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR0S12_red  ),
    .GRN                   (BR0S12_grn  ),
    .BLU                   (BR0S12_blu  ),
    .VALID                 (BR0S12_vld  ) );
 sprite #( .spriteType(0) ) BR0S13(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR0S13_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR0S13_top  ),
    .VISIBLE               (BR0S13_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR0S13_red  ),
    .GRN                   (BR0S13_grn  ),
    .BLU                   (BR0S13_blu  ),
    .VALID                 (BR0S13_vld  ) );
sprite #( .spriteType(5) ) BR0S14(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR0S14_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR0S14_top  ),
    .VISIBLE               (BR0S14_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR0S14_red  ),
    .GRN                   (BR0S14_grn  ),
    .BLU                   (BR0S14_blu  ),
    .VALID                 (BR0S14_vld  ) );
 sprite #( .spriteType(7) ) BR0S15(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR0S15_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR0S15_top  ),
    .VISIBLE               (BR0S15_vis        ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR0S15_red  ),
    .GRN                   (BR0S15_grn  ),
    .BLU                   (BR0S15_blu  ),
    .VALID                 (BR0S15_vld  ) );
    
 // ROW 2
 sprite #( .spriteType(4) ) BR1S0(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR1S0_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR1S0_top  ),
    .VISIBLE               (BR1S0_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR1S0_red  ),
    .GRN                   (BR1S0_grn  ),
    .BLU                   (BR1S0_blu  ),
    .VALID                 (BR1S0_vld  ) );
 sprite #( .spriteType(0) ) BR1S1(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR1S1_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR1S1_top  ),
    .VISIBLE               (BR1S1_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR1S1_red  ),
    .GRN                   (BR1S1_grn  ),
    .BLU                   (BR1S1_blu  ),
    .VALID                 (BR1S1_vld  ) );
sprite #( .spriteType(5) ) BR1S2(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR1S2_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR1S2_top  ),
    .VISIBLE               (BR1S2_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR1S2_red  ),
    .GRN                   (BR1S2_grn  ),
    .BLU                   (BR1S2_blu  ),
    .VALID                 (BR1S2_vld  ) );
 sprite #( .spriteType(7) ) BR1S3(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR1S3_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR1S3_top  ),
    .VISIBLE               (BR1S3_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR1S3_red  ),
    .GRN                   (BR1S3_grn  ),
    .BLU                   (BR1S3_blu  ),
    .VALID                 (BR1S3_vld  ) );
 sprite #( .spriteType(2) ) BR1S4(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR1S4_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR1S4_top  ),
    .VISIBLE               (BR1S4_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR1S4_red  ),
    .GRN                   (BR1S4_grn  ),
    .BLU                   (BR1S4_blu  ),
    .VALID                 (BR1S4_vld  ) );
 sprite #( .spriteType(6) ) BR1S5(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR1S5_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR1S5_top  ),
    .VISIBLE               (BR1S5_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR1S5_red  ),
    .GRN                   (BR1S5_grn  ),
    .BLU                   (BR1S5_blu  ),
    .VALID                 (BR1S5_vld  ) );
sprite #( .spriteType(1) ) BR1S6(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR1S6_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR1S6_top  ),
    .VISIBLE               (BR1S6_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR1S6_red  ),
    .GRN                   (BR1S6_grn  ),
    .BLU                   (BR1S6_blu  ),
    .VALID                 (BR1S6_vld  ) );
 sprite #( .spriteType(3) ) BR1S7(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR1S7_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR1S7_top  ),
    .VISIBLE               (BR1S7_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR1S7_red  ),
    .GRN                   (BR1S7_grn  ),
    .BLU                   (BR1S7_blu  ),
    .VALID                 (BR1S7_vld  ) );
 sprite #( .spriteType(4) ) BR1S8(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR1S8_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR1S8_top  ),
    .VISIBLE               (BR1S8_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR1S8_red  ),
    .GRN                   (BR1S8_grn  ),
    .BLU                   (BR1S8_blu  ),
    .VALID                 (BR1S8_vld  ) );
 sprite #( .spriteType(0) ) BR1S9(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR1S9_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR1S9_top  ),
    .VISIBLE               (BR1S9_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR1S9_red  ),
    .GRN                   (BR1S9_grn  ),
    .BLU                   (BR1S9_blu  ),
    .VALID                 (BR1S9_vld  ) );
sprite #( .spriteType(5) ) BR1S10(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR1S10_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR1S10_top  ),
    .VISIBLE               (BR1S10_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR1S10_red  ),
    .GRN                   (BR1S10_grn  ),
    .BLU                   (BR1S10_blu  ),
    .VALID                 (BR1S10_vld  ) );
 sprite #( .spriteType(7) ) BR1S11(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR1S11_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR1S11_top  ),
    .VISIBLE               (BR1S11_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR1S11_red  ),
    .GRN                   (BR1S11_grn  ),
    .BLU                   (BR1S11_blu  ),
    .VALID                 (BR1S11_vld  ) );
 sprite #( .spriteType(2) ) BR1S12(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR1S12_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR1S12_top  ),
    .VISIBLE               (BR1S12_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR1S12_red  ),
    .GRN                   (BR1S12_grn  ),
    .BLU                   (BR1S12_blu  ),
    .VALID                 (BR1S12_vld  ) );
 sprite #( .spriteType(6) ) BR1S13(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR1S13_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR1S13_top  ),
    .VISIBLE               (BR1S13_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR1S13_red  ),
    .GRN                   (BR1S13_grn  ),
    .BLU                   (BR1S13_blu  ),
    .VALID                 (BR1S13_vld  ) );
sprite #( .spriteType(1) ) BR1S14(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR1S14_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR1S14_top  ),
    .VISIBLE               (BR1S14_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR1S14_red  ),
    .GRN                   (BR1S14_grn  ),
    .BLU                   (BR1S14_blu  ),
    .VALID                 (BR1S14_vld  ) );
 sprite #( .spriteType(3) ) BR1S15(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR1S15_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR1S15_top  ),
    .VISIBLE               (BR1S15_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR1S15_red  ),
    .GRN                   (BR1S15_grn  ),
    .BLU                   (BR1S15_blu  ),
    .VALID                 (BR1S15_vld  ) );
  
//  
// ROW 3
//
sprite #( .spriteType(1) ) BR2S0(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR2S0_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR2S0_top  ),
    .VISIBLE               (BR2S0_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR2S0_red  ),
    .GRN                   (BR2S0_grn  ),
    .BLU                   (BR2S0_blu  ),
    .VALID                 (BR2S0_vld  ) );
 sprite #( .spriteType(3) ) BR2S1(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR2S1_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR2S1_top  ),
    .VISIBLE               (BR2S1_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR2S1_red  ),
    .GRN                   (BR2S1_grn  ),
    .BLU                   (BR2S1_blu  ),
    .VALID                 (BR2S1_vld  ) );
sprite #( .spriteType(6) ) BR2S2(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR2S2_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR2S2_top  ),
    .VISIBLE               (BR2S2_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR2S2_red  ),
    .GRN                   (BR2S2_grn  ),
    .BLU                   (BR2S2_blu  ),
    .VALID                 (BR2S2_vld  ) );
 sprite #( .spriteType(0) ) BR2S3(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR2S3_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR2S3_top  ),
    .VISIBLE               (BR2S3_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR2S3_red  ),
    .GRN                   (BR2S3_grn  ),
    .BLU                   (BR2S3_blu  ),
    .VALID                 (BR2S3_vld  ) );
 sprite #( .spriteType(5) ) BR2S4(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR2S4_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR2S4_top  ),
    .VISIBLE               (BR2S4_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR2S4_red  ),
    .GRN                   (BR2S4_grn  ),
    .BLU                   (BR2S4_blu  ),
    .VALID                 (BR2S4_vld  ) );
 sprite #( .spriteType(7) ) BR2S5(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR2S5_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR2S5_top  ),
    .VISIBLE               (BR2S5_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR2S5_red  ),
    .GRN                   (BR2S5_grn  ),
    .BLU                   (BR2S5_blu  ),
    .VALID                 (BR2S5_vld  ) );
sprite #( .spriteType(4) ) BR2S6(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR2S6_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR2S6_top  ),
    .VISIBLE               (BR2S6_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR2S6_red  ),
    .GRN                   (BR2S6_grn  ),
    .BLU                   (BR2S6_blu  ),
    .VALID                 (BR2S6_vld  ) );
 sprite #( .spriteType(2) ) BR2S7(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR2S7_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR2S7_top  ),
    .VISIBLE               (BR2S7_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR2S7_red  ),
    .GRN                   (BR2S7_grn  ),
    .BLU                   (BR2S7_blu  ),
    .VALID                 (BR2S7_vld  ) );
 sprite #( .spriteType(1) ) BR2S8(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR2S8_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR2S8_top  ),
    .VISIBLE               (BR2S8_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR2S8_red  ),
    .GRN                   (BR2S8_grn  ),
    .BLU                   (BR2S8_blu  ),
    .VALID                 (BR2S8_vld  ) );
 sprite #( .spriteType(3) ) BR2S9(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR2S9_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR2S9_top  ),
    .VISIBLE               (BR2S9_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR2S9_red  ),
    .GRN                   (BR2S9_grn  ),
    .BLU                   (BR2S9_blu  ),
    .VALID                 (BR2S9_vld  ) );
sprite #( .spriteType(6) ) BR2S10(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR2S10_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR2S10_top  ),
    .VISIBLE               (BR2S10_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR2S10_red  ),
    .GRN                   (BR2S10_grn  ),
    .BLU                   (BR2S10_blu  ),
    .VALID                 (BR2S10_vld  ) );
 sprite #( .spriteType(0) ) BR2S11(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR2S11_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR2S11_top  ),
    .VISIBLE               (BR2S11_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR2S11_red  ),
    .GRN                   (BR2S11_grn  ),
    .BLU                   (BR2S11_blu  ),
    .VALID                 (BR2S11_vld  ) );
 sprite #( .spriteType(5) ) BR2S12(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR2S12_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR2S12_top  ),
    .VISIBLE               (BR2S12_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR2S12_red  ),
    .GRN                   (BR2S12_grn  ),
    .BLU                   (BR2S12_blu  ),
    .VALID                 (BR2S12_vld  ) );
 sprite #( .spriteType(7) ) BR2S13(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR2S13_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR2S13_top  ),
    .VISIBLE               (BR2S13_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR2S13_red  ),
    .GRN                   (BR2S13_grn  ),
    .BLU                   (BR2S13_blu  ),
    .VALID                 (BR2S13_vld  ) );
sprite #( .spriteType(4) ) BR2S14(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR2S14_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR2S14_top  ),
    .VISIBLE               (BR2S14_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR2S14_red  ),
    .GRN                   (BR2S14_grn  ),
    .BLU                   (BR2S14_blu  ),
    .VALID                 (BR2S14_vld  ) );
 sprite #( .spriteType(2) ) BR2S15(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(BR2S15_left ),
    .SPRITE_ORIGIN_OFFSET_Y(BR2S15_top  ),
    .VISIBLE               (BR2S15_vis         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (BR2S15_red  ),
    .GRN                   (BR2S15_grn  ),
    .BLU                   (BR2S15_blu  ),
    .VALID                 (BR2S15_vld  ) );
    
 // Priority drawing function
 always @ (*)
 if (gameO_vld)
    begin
        VGA_R = gameO_red;
        VGA_G = gameO_grn;
        VGA_B = gameO_blu;
    end
 else if (ball_vld)
    begin
        VGA_R = ball_red;
        VGA_G = ball_grn;
        VGA_B = ball_blu;
    end
    else if (paddle_vld)
    begin
        VGA_R = paddle_red;
        VGA_G = paddle_grn;
        VGA_B = paddle_blu;
    end
    else if (BR2S15_vld)
    begin
        VGA_R = BR2S15_red;
        VGA_G = BR2S15_grn;
        VGA_B = BR2S15_blu;
    end
    else if (BR2S14_vld)
    begin
        VGA_R = BR2S14_red;
        VGA_G = BR2S14_grn;
        VGA_B = BR2S14_blu;
    end
    else if (BR2S13_vld)
    begin
        VGA_R = BR2S13_red;
        VGA_G = BR2S13_grn;
        VGA_B = BR2S13_blu;
    end
    else if (BR2S12_vld)
    begin
        VGA_R = BR2S12_red;
        VGA_G = BR2S12_grn;
        VGA_B = BR2S12_blu;
    end
    else if (BR2S11_vld)
    begin
        VGA_R = BR2S11_red;
        VGA_G = BR2S11_grn;
        VGA_B = BR2S11_blu;
    end
    else if (BR2S10_vld)
    begin
        VGA_R = BR2S10_red;
        VGA_G = BR2S10_grn;
        VGA_B = BR2S10_blu;
    end
    else if (BR2S9_vld)
    begin
        VGA_R = BR2S9_red;
        VGA_G = BR2S9_grn;
        VGA_B = BR2S9_blu;
    end
    else if (BR2S8_vld)
    begin
        VGA_R = BR2S8_red;
        VGA_G = BR2S8_grn;
        VGA_B = BR2S8_blu;
    end
     else if (BR2S7_vld)
    begin
        VGA_R = BR2S7_red;
        VGA_G = BR2S7_grn;
        VGA_B = BR2S7_blu;
    end
    else if (BR2S6_vld)
    begin
        VGA_R = BR2S6_red;
        VGA_G = BR2S6_grn;
        VGA_B = BR2S6_blu;
    end
    else if (BR2S5_vld)
    begin
        VGA_R = BR2S5_red;
        VGA_G = BR2S5_grn;
        VGA_B = BR2S5_blu;
    end
    else if (BR2S4_vld)
    begin
        VGA_R = BR2S4_red;
        VGA_G = BR2S4_grn;
        VGA_B = BR2S4_blu;
    end
   else if (BR2S3_vld)
    begin
        VGA_R = BR2S3_red;
        VGA_G = BR2S3_grn;
        VGA_B = BR2S3_blu;
    end
    else if (BR2S2_vld)
    begin
        VGA_R = BR2S2_red;
        VGA_G = BR2S2_grn;
        VGA_B = BR2S2_blu;
    end
      else if (BR2S1_vld)
    begin
        VGA_R = BR2S1_red;
        VGA_G = BR2S1_grn;
        VGA_B = BR2S1_blu;
    end
    else if (BR2S0_vld)
    begin
        VGA_R = BR2S0_red;
        VGA_G = BR2S0_grn;
        VGA_B = BR2S0_blu;
    end
    
    else if (BR1S15_vld)
    begin
        VGA_R = BR1S15_red;
        VGA_G = BR1S15_grn;
        VGA_B = BR1S15_blu;
    end
    else if (BR1S14_vld)
    begin
        VGA_R = BR1S14_red;
        VGA_G = BR1S14_grn;
        VGA_B = BR1S14_blu;
    end
    else if (BR1S13_vld)
    begin
        VGA_R = BR1S13_red;
        VGA_G = BR1S13_grn;
        VGA_B = BR1S13_blu;
    end
    else if (BR1S12_vld)
    begin
        VGA_R = BR1S12_red;
        VGA_G = BR1S12_grn;
        VGA_B = BR1S12_blu;
    end
    else if (BR1S11_vld)
    begin
        VGA_R = BR1S11_red;
        VGA_G = BR1S11_grn;
        VGA_B = BR1S11_blu;
    end
    else if (BR1S10_vld)
    begin
        VGA_R = BR1S10_red;
        VGA_G = BR1S10_grn;
        VGA_B = BR1S10_blu;
    end
    else if (BR1S9_vld)
    begin
        VGA_R = BR1S9_red;
        VGA_G = BR1S9_grn;
        VGA_B = BR1S9_blu;
    end
    else if (BR1S8_vld)
    begin
        VGA_R = BR1S8_red;
        VGA_G = BR1S8_grn;
        VGA_B = BR1S8_blu;
    end
     else if (BR1S7_vld)
    begin
        VGA_R = BR1S7_red;
        VGA_G = BR1S7_grn;
        VGA_B = BR1S7_blu;
    end
    else if (BR1S6_vld)
    begin
        VGA_R = BR1S6_red;
        VGA_G = BR1S6_grn;
        VGA_B = BR1S6_blu;
    end
    else if (BR1S5_vld)
    begin
        VGA_R = BR1S5_red;
        VGA_G = BR1S5_grn;
        VGA_B = BR1S5_blu;
    end
    else if (BR1S4_vld)
    begin
        VGA_R = BR1S4_red;
        VGA_G = BR1S4_grn;
        VGA_B = BR1S4_blu;
    end
   else if (BR1S3_vld)
    begin
        VGA_R = BR1S3_red;
        VGA_G = BR1S3_grn;
        VGA_B = BR1S3_blu;
    end
    else if (BR1S2_vld)
    begin
        VGA_R = BR1S2_red;
        VGA_G = BR1S2_grn;
        VGA_B = BR1S2_blu;
    end
      else if (BR1S1_vld)
    begin
        VGA_R = BR1S1_red;
        VGA_G = BR1S1_grn;
        VGA_B = BR1S1_blu;
    end
    else if (BR1S0_vld)
    begin
        VGA_R = BR1S0_red;
        VGA_G = BR1S0_grn;
        VGA_B = BR1S0_blu;
    end
    else if (BR0S15_vld)
    begin
        VGA_R = BR0S15_red;
        VGA_G = BR0S15_grn;
        VGA_B = BR0S15_blu;
    end
    else if (BR0S14_vld)
    begin
        VGA_R = BR0S14_red;
        VGA_G = BR0S14_grn;
        VGA_B = BR0S14_blu;
    end
    else if (BR0S13_vld)
    begin
        VGA_R = BR0S13_red;
        VGA_G = BR0S13_grn;
        VGA_B = BR0S13_blu;
    end
    else if (BR0S12_vld)
    begin
        VGA_R = BR0S12_red;
        VGA_G = BR0S12_grn;
        VGA_B = BR0S12_blu;
    end
    else if (BR0S11_vld)
    begin
        VGA_R = BR0S11_red;
        VGA_G = BR0S11_grn;
        VGA_B = BR0S11_blu;
    end
    else if (BR0S10_vld)
    begin
        VGA_R = BR0S10_red;
        VGA_G = BR0S10_grn;
        VGA_B = BR0S10_blu;
    end
    else if (BR0S9_vld)
    begin
        VGA_R = BR0S9_red;
        VGA_G = BR0S9_grn;
        VGA_B = BR0S9_blu;
    end
    else if (BR0S8_vld)
    begin
        VGA_R = BR0S8_red;
        VGA_G = BR0S8_grn;
        VGA_B = BR0S8_blu;
    end
     else if (BR0S7_vld)
    begin
        VGA_R = BR0S7_red;
        VGA_G = BR0S7_grn;
        VGA_B = BR0S7_blu;
    end
    else if (BR0S6_vld)
    begin
        VGA_R = BR0S6_red;
        VGA_G = BR0S6_grn;
        VGA_B = BR0S6_blu;
    end
    else if (BR0S5_vld)
    begin
        VGA_R = BR0S5_red;
        VGA_G = BR0S5_grn;
        VGA_B = BR0S5_blu;
    end
    else if (BR0S4_vld)
    begin
        VGA_R = BR0S4_red;
        VGA_G = BR0S4_grn;
        VGA_B = BR0S4_blu;
    end
   else if (BR0S3_vld)
    begin
        VGA_R = BR0S3_red;
        VGA_G = BR0S3_grn;
        VGA_B = BR0S3_blu;
    end
    else if (BR0S2_vld)
    begin
        VGA_R = BR0S2_red;
        VGA_G = BR0S2_grn;
        VGA_B = BR0S2_blu;
    end
      else if (BR0S1_vld)
    begin
        VGA_R = BR0S1_red;
        VGA_G = BR0S1_grn;
        VGA_B = BR0S1_blu;
    end
    else if (BR0S0_vld)
    begin
        VGA_R = BR0S0_red;
        VGA_G = BR0S0_grn;
        VGA_B = BR0S0_blu;
    end
    else
    begin
        VGA_R = 0;
        VGA_G = 0;
        VGA_B = 0;
    end
     
`else
    
    // Refresh memory mode
    reg [4:0] present_state;
    reg [4:0] next_state;
    parameter idle = 5'b00001;
    parameter edge_a = 5'b00010;
    parameter edge_b = 5'b00100;
    parameter edge_c = 5'b01000;
    parameter done = 5'b10000;
    wire [18:0] write_addr;
    wire [18:0] read_addr;
    reg [7:0] d_in;
    wire [7:0] d_out;
    reg write_enable;
    reg [9:0] x0, x1, x2;
    reg [8:0] y0, y1, y2;
    reg [9:0] half_length;
    reg [9:0] mar_x;
    reg [8:0] mar_y;
    
    //define every color so you can mix intensities

    assign read_addr = {H_count_value[9:0], V_count_value[8:0]}; //addra
    assign write_addr = {mar_x, mar_y}; //addrb

    always @ (posedge clk)
    begin
        if(reset)
        begin
            
        end
    end
    
    always @ (posedge clk)
    begin
        if(reset)
        begin
            present_state   <= idle;
            
            mar_x           <= x0;
            mar_y           <= y0;
            
            write_enable    <= 0;
            
            VGA_R <= 0;
            VGA_G <= 0;
            VGA_B <= 0;

            x0 <= 10'd20;
            y0 <= 9'd460; //111001100

            half_length <= 10'd300;

            x1 <= x0 + (2*half_length);
            y1 <= y0;
            x2 <= x0 + (half_length);
            y2 <= y0 - (half_length);

            d_in <= 8'b11111111;
        end
        else
        begin
            case(present_state)
                idle:
                begin
                    present_state   <= edge_a;
                    write_enable    <= 1;

                    mar_x <= x0;
                    mar_y <= y0;
                    
                    VGA_R <= 0;
                    VGA_G <= 0;
                    VGA_B <= 0;
        
                    x1 <= x0 + (2*half_length);
                    y1 <= y0;
                    x2 <= x0 + (half_length);
                    y2 <= y0 - (half_length);
                end
                    
                edge_a:
                begin
                    mar_x <= mar_x + 1;
                    if(mar_x == (x1-1))
                        present_state <= edge_b;
                end
                edge_b:
                begin
                    mar_x <= mar_x - 1;
                    mar_y <= mar_y - 1;
                    if(mar_x == (x2+1))
                        present_state <= edge_c;
                    
                end
                edge_c:
                begin
                    mar_x <= mar_x - 1;
                    mar_y <= mar_y + 1;
                    if(mar_x == (x0+1))
                        present_state <= done;
                end
                done:
                begin
                    x0 <= x0 + 2; //moves right 4
                    y0 <= y0 - 2; //moves up 4
                    d_in <= d_in - 1;
                    if ( half_length > 20)
                    begin
                        half_length <= half_length - 4;
                        present_state <= idle;
                    end
                    else
                        write_enable <= 0;
                end
                default:
                    present_state <= idle;
            endcase
            
            VGA_R <= {d_out[5:4],{2{d_out[4]}}};
            VGA_G <= {d_out[3:2],{2{d_out[2]}}};
            VGA_B <= {d_out[1:0],{2{d_out[0]}}};
        
        end
    end

`endif
    
    //blk_mem_gen_0 ram(clk, write_enable, write_addr, d_in, clk, read_addr, d_out);
    clk_wiz_0 CLKWIZ0(.clk_out1(clk), .resetn(1'b1), .locked(locked), .clk_in1(clk_in1));
    
endmodule