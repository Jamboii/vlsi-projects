`timescale 1ns / 1ps

module FSM(input logic clk,
           input logic rs,
           input logic p1,
           input logic p2,
           output logic [2:0] Y);
           
    // create a type definition for each of the states
    typedef enum logic [2:0] {deuce=3'b000, addout=3'b001, addin=3'b010, game1=3'b011, game2=3'b100} State;
    
    // create states for current and next state
    State currState, nextState;
        
    // flip-flop for clock alternation and resets
    always @(posedge clk)        
        if (rs)      currState <= deuce;
        else         currState <= nextState;
        
    // combinational loop for state changes
    always_comb
        case (currState)
            deuce: if (!rs && p1 && !p2)       nextState = addout;
                   else if (!rs && !p1 && p2)  nextState = addin;
                   else                        nextState = deuce;
            
            addout: if (!rs && p1 && !p2)      nextState = game1;
                    else if (!rs && !p1 && p2) nextState = deuce;
                    else                       nextState = addout;
                    
            addin: if (!rs && p1 && !p2)       nextState = deuce;
                   else if (!rs && !p1 && p2)  nextState = game2;
                   else                        nextState = addin;
                   
            game1:                             nextState = deuce;
            
            game2:                             nextState = deuce;
            default:                           nextState = deuce;
        endcase
            
    // assign output to current state
    assign Y = currState;

endmodule