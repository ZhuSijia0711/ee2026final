`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/06 20:11:01
// Design Name: 
// Module Name: replay_control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module replay_control(
    input clk,
    input video_on,
    input [11:0] x, y,
    input [1:0] mode,
    input [7:0]step_to_replay, 
    input [7:0]step_number,
    output reg [11:0] rgb_chess,
    output reg is_chess
);

    localparam GRID_WIDTH = 15;
    localparam GRID_HEIGHT = 15;
    localparam GRID_SPACING_X = 20;
    localparam GRID_SPACING_Y = 20;
    localparam GRID_START_X = 50;
    localparam GRID_START_Y = 100;
    localparam CHESS_RADIUS = 7;
    localparam BLACK = 12'h000;
    localparam WHITE= 12'hFFF;

    reg [3:0]x_replay;
    reg [3:0]y_replay;
    reg [14:0] position_black [14:0];
    reg [14:0] position_white [14:0];
    reg color = 0;
    reg [3:0] i,j;
    reg [11:0]center_x;
    reg [11:0]center_y;
    reg [11:0]dx;
    reg [11:0]dy;
        
    initial begin
        color = 0;
        position_black[0] = 15'd0;
        position_black[1] = 15'd0;
        position_black[2] = 15'd0;
        position_black[3] = 15'd0;
        position_black[4] = 15'd0;
        position_black[5] = 15'd0;
        position_black[6] = 15'd0;
        position_black[7] = 15'd0;
        position_black[8] = 15'd0;
        position_black[9] = 15'd0;
        position_black[10] = 15'd0;
        position_black[11] = 15'd0;
        position_black[12] = 15'd0;
        position_black[13] = 15'd0;
        position_black[14] = 15'd0;
        
        position_white[0] = 15'd0;
        position_white[1] = 15'd0;
        position_white[2] = 15'd0;
        position_white[3] = 15'd0;
        position_white[4] = 15'd0;
        position_white[5] = 15'd0;
        position_white[6] = 15'd0;
        position_white[7] = 15'd0;
        position_white[8] = 15'd0;
        position_white[9] = 15'd0;
        position_white[10] = 15'd0;
        position_white[11] = 15'd0;
        position_white[12] = 15'd0;
        position_white[13] = 15'd0;
        position_white[14] = 15'd0;   

    end
    
    always @(posedge clk) begin 
        if (mode == 2'b11) begin 
            x_replay = step_to_replay[7:4];
            y_replay = step_to_replay[3:0];
            if (step_number % 2 == 1) begin // Black's turn
                position_black[x_replay][y_replay] = 1;
                color = 0;
            end else if (step_number != 0) begin // White's turn
                position_white[x_replay][y_replay] = 1;
                color = 1;
            end
        end
        else begin
            position_black[0] <= 15'd0;
            position_black[1] <= 15'd0;
            position_black[2] <= 15'd0;
            position_black[3] <= 15'd0;
            position_black[4] <= 15'd0;
            position_black[5] <= 15'd0;
            position_black[6] <= 15'd0;
            position_black[7] <= 15'd0;
            position_black[8] <= 15'd0;
            position_black[9] <= 15'd0;
            position_black[10] <= 15'd0;
            position_black[11] <= 15'd0;
            position_black[12] <= 15'd0;
            position_black[13] <= 15'd0;
            position_black[14] <= 15'd0;
            
            position_white[0] <= 15'd0;
            position_white[1] <= 15'd0;
            position_white[2] <= 15'd0;
            position_white[3] <= 15'd0;
            position_white[4] <= 15'd0;
            position_white[5] <= 15'd0;
            position_white[6] <= 15'd0;
            position_white[7] <= 15'd0;
            position_white[8] <= 15'd0;
            position_white[9] <= 15'd0;
            position_white[10] <= 15'd0;
            position_white[11] <= 15'd0;
            position_white[12] <= 15'd0;
            position_white[13] <= 15'd0;
            position_white[14] <= 15'd0;
        end
        
        // chess display    
        if ((x >= GRID_START_X-10) && (x < GRID_START_X + (GRID_WIDTH-1) * GRID_SPACING_X+10) && (y >= GRID_START_Y-10) && (y < GRID_START_Y + (GRID_HEIGHT-1) * GRID_SPACING_Y+10)) begin
            i = (x - GRID_START_X + GRID_SPACING_X/2) / GRID_SPACING_X;
            j = (y - GRID_START_Y + GRID_SPACING_Y/2) / GRID_SPACING_Y;
            center_x = i * GRID_SPACING_X + GRID_START_X;
            center_y = j * GRID_SPACING_Y + GRID_START_Y;
            dx = (x > center_x) ? (x - center_x) : (center_x - x);
            dy = (y > center_y) ? (y - center_y) : (center_y - y);
            if (position_black[i][j]==1) begin 
                is_chess = ((dx * dx + dy * dy) <= (CHESS_RADIUS * CHESS_RADIUS));
                rgb_chess = BLACK;
            end else if (position_white[i][j]==1) begin 
                is_chess = ((dx * dx + dy * dy) <= (CHESS_RADIUS * CHESS_RADIUS));
                rgb_chess = WHITE;
            end else begin
                is_chess = 0;
            end
        end

    end

endmodule
