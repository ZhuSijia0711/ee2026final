`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/06 21:49:12
// Design Name: 
// Module Name: replay_control_animation
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


module replay_control_animation(
    input clk,
    input video_on,
    input [9:0] x, y,
    output reg [11:0] rgb,
    output is_control
);
    
// signal declarations
wire [10:0] rom_addr;           // 11-bit text ROM address
wire [6:0] ascii_char;          // 7-bit ASCII character code

wire [3:0] char_row;            // 4-bit row of ASCII character
wire [2:0] bit_addr;            // column number of ROM data
wire [7:0] rom_data;            // 8-bit row data from text ROM
wire ascii_bit, ascii_bit_on;     // ROM bit and status signal

// instantiate ASCII ROM
ascii_rom rom(.clk(clk), .addr(rom_addr), .data(rom_data));
  
// ASCII ROM interface
assign rom_addr = {ascii_char, char_row};   // ROM address is ascii code + row
assign ascii_bit = rom_data[~bit_addr];     // reverse bit order
                    
assign ascii_char = (x >= 320 && x < 328) ? 7'h51 :  //Q
                    (x >= 328 && x < 336) ? 7'h55 :  //U
                    (x >= 336 && x < 344) ? 7'h49 :  //I
                    (x >= 344 && x < 352) ? 7'h54 :  //T                       
                    7'h00;
                    
assign char_row = y[3:0];               // row number of ascii character rom
assign bit_addr = x[2:0];               // column number of ascii character rom
// "on" region in center of screen
assign ascii_bit_on = ((x >= 280 && x < 392) && (y >= 64 && y < 80)) ? ascii_bit: 1'b0;

assign is_control = (x >= 280 && x < 392) && (y >= 64 && y < 80);

// rgb multiplexing circuit
always @*
    if(~video_on)
        rgb = 12'h000;      // blank
    else
        if(ascii_bit_on)
        begin
            rgb = 12'h641;  // navy blue coloured letters
        end
        else
            rgb = 12'hFFF;  // white background

endmodule
