`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/03 10:46:42
// Design Name: 
// Module Name: start_game
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


module start_game(
    input clk,
    input video_on,
    input [9:0] x, y,
    output reg [11:0] rgb,
    output st_g
    );
    wire [10:0] rom_addr;           // 11-bit text ROM address
    wire [6:0] ascii_char;          // 7-bit ASCII character code
    wire [3:0] char_row;            // 4-bit row of ASCII character
    wire [2:0] bit_addr;            // column number of ROM data
    wire [7:0] rom_data;            // 8-bit row data from text ROM
    wire ascii_bit, ascii_bit_on;     // ROM bit and status signal
    
    assign st_g = ((x >= 224 & x < 400) & (y >= 224 & y < 240));
    // instantiate ASCII ROM
    ascii_rom rom(.clk(clk), .addr(rom_addr), .data(rom_data));
      
    // ASCII ROM interface
    assign rom_addr = {ascii_char, char_row};   // ROM address is ascii code + row
    assign ascii_bit = rom_data[~bit_addr];     // reverse bit order

    localparam START_S=224;
    assign ascii_char = (x >= START_S && x < START_S+8) ? 7'h53: //S
                        (x >= START_S+8 && x < START_S+16) ? 7'h54: //T
                        (x >= START_S+16 && x < START_S+24) ? 7'h41: //A
                        (x >= START_S+24 && x < START_S+32) ? 7'h52: //R
                        (x >= START_S+32 && x < START_S+40) ? 7'h54: //T
                        (x >= START_S+48 && x < START_S+56) ? 7'h47: //G
                        (x >= START_S+56 && x < START_S+64) ? 7'h41: //A
                        (x >= START_S+64 && x < START_S+72) ? 7'h4d: //M
                        (x >= START_S+72 && x < START_S+80) ? 7'h45: //E
                        
                        (x >= 352 && x < 360) ? 7'h52: //R
                        (x >= 360 && x < 368) ? 7'h45: //E
                        (x >= 368 && x < 376) ? 7'h50: //P
                        (x >= 376 && x < 384) ? 7'h4c: //L
                        (x >= 384 && x < 392) ? 7'h41: //A
                        (x >= 392 && x < 400) ? 7'h59: //Y
                        7'h00;
                       
    assign char_row = y[3:0];               // row number of ascii character rom
    assign bit_addr = x[2:0];               // column number of ascii character rom
    // "on" region in center of screen
    assign ascii_bit_on = ((x >= START_S && x < 400) && (y >= 224 && y < 240)) ? ascii_bit : 1'b0;
    
    // rgb multiplexing circuit
    always @ (posedge clk) begin
        if(~video_on)
            rgb = 12'h000;      // blank
        else
            if(ascii_bit_on)
                rgb = 12'h00F;  // blue letters
            else
                rgb = 12'hFFF;  // white background
    end
   
endmodule
