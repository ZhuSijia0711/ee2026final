`timescale 1ns / 1ps

module board_animation(
    input clk,
    input video_on,
    input [11:0] x, y,
    output reg [11:0] rgb,
    input [11:0] x_in,
    input [11:0] y_in,
    input clicked,
    output is_grid
);

wire board_bit_on;
wire vertical_line;
wire horizontal_line;
wire intersection;
wire pA;
wire pB;
wire [343:0]clickedx;
wire [383:0]clickedy;
wire clicked1;
wire clicked2;

// Define grid parameters
localparam GRID_WIDTH = 15; // Width of the grid (number of columns)
localparam GRID_HEIGHT = 15; // Height of the grid (number of rows)
localparam GRID_SPACING_X = 20; // Spacing between vertical grid lines
localparam GRID_SPACING_Y = 20; // Spacing between horizontal grid lines
localparam GRID_THICKNESS = 1; // Thickness of grid lines

// Calculate starting position of the grid to place it at the left middle of the screen
localparam GRID_START_X = 50; // Adjust as needed for the left padding
localparam GRID_START_Y = 100; // Adjust as needed for the top padding

assign board_bit_on = (vertical_line | horizontal_line);
assign is_grid = (vertical_line | horizontal_line);

// Check if the current pixel is on a vertical line
assign vertical_line = ((x >= GRID_START_X) && (x < (GRID_START_X + (GRID_WIDTH - 1) * GRID_SPACING_X) + 1) &&
                        ((x - GRID_START_X) % GRID_SPACING_X) < GRID_THICKNESS &&
                        (y >= GRID_START_Y) && (y < (GRID_START_Y + (GRID_HEIGHT - 1) * GRID_SPACING_Y) + 1));

// Check if the current pixel is on a horizontal line
assign horizontal_line = ((y >= GRID_START_Y) && (y < (GRID_START_Y + (GRID_HEIGHT - 1) * GRID_SPACING_Y) + 1) &&
                          ((y - GRID_START_Y) % GRID_SPACING_Y) < GRID_THICKNESS &&
                         (x >= GRID_START_X) && (x < (GRID_START_X + (GRID_WIDTH - 1) * GRID_SPACING_X) + 1));

// Check if the current pixel is at an intersection point
assign intersection = vertical_line & horizontal_line;                      

//assign clicked1 = clicked;

assign pA = intersection && clicked1 && (x <= x_in + 3) && (x >= x_in - 3) && (y <= y_in + 3) && (y >= y_in - 3);
assign pB = intersection & clicked2;

// rgb multiplexing circuit
always @*
    if(~video_on)
        rgb = 12'h000;      // blank
    else
    begin
        if(board_bit_on)
            rgb = 12'hFFF;  // black      
//        else if (pA)
//            rgb = 12'h100;
//        else if (pB)  
//            rgb = 12'h010;
        else
            rgb = 12'h6AD;  // yellowish brown background
    end
endmodule