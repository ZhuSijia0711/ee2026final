`timescale 1ns / 1ps

module player_animation(
    input clk,
    input video_on,
    input [9:0] x, y,
    output reg [11:0] rgb,
    output is_player_display
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
    
    //465, 120 //465, 290
    //assign ascii_char = {y[5:4], x[7:3]};   // 7-bit ascii code
    assign ascii_char = (x >= 464 && x < 472) ? 7'h50 :  //P
                        (x >= 472 && x < 480) ? 7'h4c :  //L
                        (x >= 480 && x < 488) ? 7'h41 :  //A
                        (x >= 488 && x < 496) ? 7'h59 :  //Y
                        (x >= 496 && x < 504) ? 7'h45 :  //E
                        (x >= 504 && x < 512) ? 7'h52 :  //R
                        (x >= 512 && x < 520) ? 7'h00 :  //SPACE
                        (x >= 520 && x < 528) && (y >= 128 && y < 144) ? 7'h41 :  //A 
                        (x >= 520 && x < 528) && (y >= 286 && y < 302) ? 7'h42 :  //B       
                        7'h00;
                        
    assign char_row = y[3:0];               // row number of ascii character rom
    assign bit_addr = x[2:0];               // column number of ascii character rom
    // "on" region in center of screen
    assign ascii_bit_on = ((x >= 464 && x < 528)) ? ascii_bit: 1'b0;
    
    assign is_player_display = (x >= 464 && x < 528) && ((y >= 128 && y < 144) || (y >= 286 && y < 302));
    
    // rgb multiplexing circuit
    always @*     if(~video_on)
            rgb = 12'h000;      // blank
        else
            if(ascii_bit_on) 
            begin
                rgb = 12'h000;  // black letters
            end
            else
                rgb = 12'hFFF;  // white background
   
endmodule