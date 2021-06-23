`timescale 1ns / 1ps

module sprite
#( parameter
    spriteType = 15   // 0-7 denotes the block style, 8 is the ball, 9 is the paddle
)
(
    input CLK,
    input RESET,
    
    input [9:0] SPRITE_ORIGIN_OFFSET_X,
    input [8:0] SPRITE_ORIGIN_OFFSET_Y,
    input VISIBLE,
    input [9:0] RASTER_X,
    input [8:0] RASTER_Y,
    
    output [3:0] RED,
    output [3:0] GRN,
    output [3:0] BLU,
    output VALID
    );
    
    wire [9:0] sprite_local_x;      // local position of raster
    wire [8:0] sprite_local_y;      // within this sprite
    wire in_sprite_rect;            // tells whether the raster is in the sprite
    
    assign sprite_local_x = RASTER_X - SPRITE_ORIGIN_OFFSET_X;
    assign sprite_local_y = RASTER_Y - SPRITE_ORIGIN_OFFSET_Y;

    wire [7:0] red_t;    
    wire [7:0] grn_t;    
    wire [7:0] blu_t;    
     
    integer SPRITE_WID;
    integer SPRITE_HGT;
    
  always @ (*)
  begin
      case (spriteType)
          8: begin // ball sprite
              SPRITE_HGT=20;
              SPRITE_WID=20;
          end
          9: begin // paddle sprite
              SPRITE_HGT=40;
              SPRITE_WID=120;
          end
          /*10: begin // gameover sprite
              SPRITE_HGT=160;
              SPRITE_WID=214;
          end
          */
          default: begin // block sprite
              SPRITE_HGT=40;
              SPRITE_WID=40;
          end
  endcase
  end
  
  generate
    case (spriteType)
         0: begin                                                   // YELLOW
             yellowBlock_40x40_rom yellowBlock_40x40_rom(
                 .x_idx(sprite_local_x[5:0]),
                 .y_idx(sprite_local_y[5:0]),
                 .RED  (red_t  ),
                 .GRN  (grn_t  ),
                 .BLU  (blu_t  ));
             end
         1:begin                                                    // TCNJ
             tcnjBlock_40x40_rom tcnjBlock_40x40_rom(
                 .x_idx(sprite_local_x[5:0]),
                 .y_idx(sprite_local_y[5:0]),
                 .RED  (red_t  ),
                 .GRN  (grn_t  ),
                 .BLU  (blu_t  ));
             end
         2:begin                                                    // ROAR
             roscoeRoarBlock_40x40_rom roscoeRoarBlock_40x40_rom(
                 .x_idx(sprite_local_x[5:0]),
                 .y_idx(sprite_local_y[5:0]),
                 .RED  (red_t  ),
                 .GRN  (grn_t  ),
                 .BLU  (blu_t  ));
             end
         3:begin                                                    // CARTOON HEAD
             roscoeHeadBlock_40x40_rom roscoeHeadBlock_40x40_rom(
                 .x_idx(sprite_local_x[5:0]),
                 .y_idx(sprite_local_y[5:0]),
                 .RED  (red_t  ),
                 .GRN  (grn_t  ),
                 .BLU  (blu_t  ));
             end
         4:begin                                                    // TCNJ PAW
             pawBlock_40x40_rom pawBlock_40x40_rom(
                 .x_idx(sprite_local_x[5:0]),
                 .y_idx(sprite_local_y[5:0]),
                 .RED  (red_t  ),
                 .GRN  (grn_t  ),
                 .BLU  (blu_t  ));
             end
         5:begin                                                    // EMBLEM
             embBlock_40x40_rom embBlock_40x40_rom(
                 .x_idx(sprite_local_x[5:0]),
                 .y_idx(sprite_local_y[5:0]),
                 .RED  (red_t  ),
                 .GRN  (grn_t  ),
                 .BLU  (blu_t  ));
             end
         6:begin                                                    // BRONZE LION
             bronzeBlock_40x40_rom bronzeBlock_40x40_rom(
                 .x_idx(sprite_local_x[5:0]),
                 .y_idx(sprite_local_y[5:0]),
                 .RED  (red_t  ),
                 .GRN  (grn_t  ),
                 .BLU  (blu_t  ));
             end
         7:begin                                                    // BLUE
             blueBlock_40x40_rom blueBlock_40x40_rom(
                 .x_idx(sprite_local_x[5:0]),
                 .y_idx(sprite_local_y[5:0]),
                 .RED  (red_t  ),
                 .GRN  (grn_t  ),
                 .BLU  (blu_t  ));
             end
         8: begin                                                   // BALL
             ball_20x20_rom ball_20x20_rom(
                 .x_idx(sprite_local_x[5:0]),
                 .y_idx(sprite_local_y[5:0]),
                 .RED  (red_t  ),
                 .GRN  (grn_t  ),
                 .BLU  (blu_t  ));
             end
         9:begin                                                    // PADDLE
             paddle_120x40_rom paddle_120x40_rom(
                 .x_idx(sprite_local_x[6:0]),
                 .y_idx(sprite_local_y[5:0]),
                 .RED  (red_t  ),
                 .GRN  (grn_t  ),
                 .BLU  (blu_t  ));
             end
         /*10:begin                                                   // GAME OVER
             gameO_214x160_rom gameO_214x160_rom(
                 .x_idx(sprite_local_x[7:0]),
                 .y_idx(sprite_local_y[7:0]),
                 .RED  (red_t  ),
                 .GRN  (grn_t  ),
                 .BLU  (blu_t  ));
             end*/
         default: begin                                             // REGULAR LION
             lp_40x40 lp_40x40(
                 .x_idx(sprite_local_x[5:0]),
                 .y_idx(sprite_local_y[5:0]),
                 .RED  (red_t  ),
                 .GRN  (grn_t  ),
                 .BLU  (blu_t  ));
             end
     endcase
    endgenerate
     
    assign in_sprite_rect = (RASTER_X >= SPRITE_ORIGIN_OFFSET_X) &&
                            (RASTER_X < SPRITE_ORIGIN_OFFSET_X + SPRITE_WID) &&
                            (RASTER_Y >= SPRITE_ORIGIN_OFFSET_Y) &&
                            (RASTER_Y < SPRITE_ORIGIN_OFFSET_Y + SPRITE_HGT);
                            
    assign VALID = in_sprite_rect & VISIBLE;
    
    assign RED = red_t[7:4];    
    assign GRN = grn_t[7:4];    
    assign BLU = blu_t[7:4];    
endmodule