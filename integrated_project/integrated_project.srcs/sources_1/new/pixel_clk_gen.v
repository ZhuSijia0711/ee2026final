

`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////
// Authored by David J. Marion aka FPGA Dude
// Created on 4/11/2022
//
// Purpose: receive clock BCD values, write clock on VGA screen
///////////////////////////////////////////////////////////////////////

module pixel_clk_gen(
    input clk,
    input video_on,
    //input tick_1Hz,       // use signal if blinking colon(s) is desired
    input [9:0] x, y,
    input [3:0] sec_1s, sec_10s,
    input [3:0] min_1s,
    output reg [11:0] time_rgb,
    output is_timer_display_black
    );
    
    // Minute 1s Digit section = 32 x 64
    localparam M1_X_L = 438;
    localparam M1_X_R = 470;
    localparam M1_Y_T = 176;
    localparam M1_Y_B = 240;
    
    // Colon 2 section = 32 x 64
    localparam C2_X_L = 470;
    localparam C2_X_R = 502;
    localparam C2_Y_T = 176;
    localparam C2_Y_B = 240;
    
    // Second 10s Digit section = 32 x 64
    localparam S10_X_L = 502;
    localparam S10_X_R = 534;
    localparam S10_Y_T = 176;
    localparam S10_Y_B = 240;
    
    // Second 1s Digit section = 32 x 64
    localparam S1_X_L = 534;
    localparam S1_X_R = 566;
    localparam S1_Y_T = 176;
    localparam S1_Y_B = 240;

    // Object Status Signals
    wire M1_on, C2_on, S10_on, S1_on;
    
    // ROM Interface Signals
    wire [10:0] rom_addr;
    reg [6:0] char_addr;   // 3'b011 + BCD value of time component
    wire [6:0] char_addr_m1, char_addr_s10, char_addr_s1, char_addr_c2;

    reg [3:0] row_addr;    // row address of digit
    wire [3:0] row_addr_m1, row_addr_s10, row_addr_s1, row_addr_c2;

    reg [2:0] bit_addr;    // column address of rom data
    wire [2:0] bit_addr_m1, bit_addr_s10, bit_addr_s1, bit_addr_c2;
 
    wire [7:0] digit_word;  // data from rom
    wire digit_bit;
    
    wire [9:0] y_m1, y_s10, y_s1, y_c2;
    wire [9:0] x_m1, x_s10, x_s1, x_c2;
    
    // Instantiate digit rom
    clock_digit_rom cdr(.clk(clk), .addr(rom_addr), .data(digit_word)); //first clock
    
    assign is_timer_display_black = (x >= 438 && x < 566) && (y >= 176 && y < 240);
    
    assign char_addr_m1 = {3'b011, min_1s};
    assign y_m1 = y - M1_Y_T;
    assign row_addr_m1 = y_m1[5:2];   // scaling to 32x64
    assign x_m1 = x - M1_X_L;
    assign bit_addr_m1 = x_m1[4:2];   // scaling to 32x64
    
    assign char_addr_c2 = 7'h3a;
    assign y_c2 = y - C2_Y_T;
    assign row_addr_c2 = y_c2[5:2];    // scaling to 32x64
    assign x_c2 = x - C2_X_L;
    assign bit_addr_c2 = x_c2[4:2];    // scaling to 32x64
    
    assign char_addr_s10 = {3'b011, sec_10s};
    assign y_s10 = y - S10_Y_T;
    assign row_addr_s10 = y_s10[5:2];   // scaling to 32x64
    assign x_s10 = x - S10_X_L;
    assign bit_addr_s10 = x_s10[4:2];   // scaling to 32x64
    
    assign char_addr_s1 = {3'b011, sec_1s};
    assign y_s1 = y - S1_Y_T;
    assign row_addr_s1 = y_s1[5:2];   // scaling to 32x64
    assign x_s1 = x - S1_X_L;
    assign bit_addr_s1 = x_s1[4:2];   // scaling to 32x64
    
    // Minute sections assert signals
    assign M1_on =  (M1_X_L <= x) && (x < M1_X_R) &&
                    (M1_Y_T <= y) && (y < M1_Y_B);                             
    
    // Colon 2 ROM assert signals
    assign C2_on = (C2_X_L <= x) && (x < C2_X_R) &&
                   (C2_Y_T <= y) && (y < C2_Y_B);
                  
    // Second sections assert signals
    assign S10_on = (S10_X_L <= x) && (x < S10_X_R) &&
                    (S10_Y_T <= y) && (y < S10_Y_B);
    assign S1_on =  (S1_X_L <= x) && (x < S1_X_R) &&
                    (S1_Y_T <= y) && (y < S1_Y_B);
                    
    // Mux for ROM Addresses and RGB    
    always @(posedge clk) begin
        time_rgb = 12'hFFF;

        if(M1_on) begin
            char_addr = char_addr_m1;
            row_addr = row_addr_m1;
            bit_addr = bit_addr_m1;
            if(digit_bit)
                time_rgb = 12'hF00;     
        end
        else if(C2_on) begin
            char_addr = char_addr_c2;
            row_addr = row_addr_c2;
            bit_addr = bit_addr_c2;
            if(digit_bit)
                time_rgb = 12'hF00;    
        end
        else if(S10_on) begin
            char_addr = char_addr_s10;
            row_addr = row_addr_s10;
            bit_addr = bit_addr_s10;
            if(digit_bit)
                time_rgb = 12'hF00;    
        end
        else if(S1_on) begin
            char_addr = char_addr_s1;
            row_addr = row_addr_s1;
            bit_addr = bit_addr_s1;
            if(digit_bit)
                time_rgb = 12'hF00;     
        end
        else time_rgb = 12'hFFF;
    end
    
    // ROM Interface    
    assign rom_addr = {char_addr, row_addr};
    assign digit_bit = digit_word[~bit_addr]; 
                          
endmodule
