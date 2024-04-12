`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/02 15:10:54
// Design Name: 
// Module Name: pixel_clk_gen2
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

module pixel_clk_gen2(
    input clk,
    input video_on,
    //input tick_1Hz,       // use signal if blinking colon(s) is desired
    input [9:0] x, y,
    input [3:0] sec_1s, sec_10s,
    input [3:0] min_1s,
    output reg [11:0] time_rgb,
    output is_timer_display_white
    );
    //wire board_bit_on;

    assign is_timer_display_white = (x >= 438 & x < 566) & (y>=336 & y < 400);
    
    // Minute 1s Digit section = 32 x 64
    localparam M1_X_L2 = 438;
    localparam M1_X_R2 = 470;
    localparam M1_Y_T2 = 336;
    localparam M1_Y_B2 = 400;
    
    // Colon 2 section = 32 x 64
    localparam C2_X_L2 = 470;
    localparam C2_X_R2 = 502;
    localparam C2_Y_T2 = 336;
    localparam C2_Y_B2 = 400;
    
    // Second 10s Digit section = 32 x 64
    localparam S10_X_L2 = 502;
    localparam S10_X_R2 = 534;
    localparam S10_Y_T2 = 336;
    localparam S10_Y_B2 = 400;
    
    // Second 1s Digit section = 32 x 64
    localparam S1_X_L2 = 534;
    localparam S1_X_R2 = 566;
    localparam S1_Y_T2 = 336;
    localparam S1_Y_B2 = 400;
    
    // Object Status Signals
    wire M1_on2, C2_on2, S10_on2, S1_on2;
    
    // ROM Interface Signals
    wire [6:0] char_addr_m12, char_addr_s102, char_addr_s12, char_addr_c22;    // row address of digit
    wire [3:0] row_addr_m12, row_addr_s102, row_addr_s12, row_addr_c22;
    wire [2:0] bit_addr_m12, bit_addr_s102, bit_addr_s12, bit_addr_c22;  
    reg [2:0] bit_addr2; 
    wire digit_bit2;
    reg [3:0] row_addr2; 
    reg [6:0] char_addr2;
    wire [10:0] rom_addr2;
    wire [7:0] digit_word2;
    
    wire [9:0] y_m1, y_s10, y_s1, y_c2;
    wire [9:0] x_m1, x_s10, x_s1, x_c2;
    
    clock_digit_rom cdr2(.clk(clk), .addr(rom_addr2), .data(digit_word2)); //second clock  
       
    assign char_addr_m12 = {3'b011, min_1s};
    assign y_m1 = y - M1_Y_T2;
    assign row_addr_m12 = y_m1[5:2];   // scaling to 32x64
    assign x_m1 = x - M1_X_L2;
    assign bit_addr_m12 = x_m1[4:2];   // scaling to 32x64
    
    assign char_addr_c22 = 7'h3a;
    assign y_c2 = y - C2_Y_T2;
    assign row_addr_c22 = y_c2[5:2];    // scaling to 32x64
    assign x_c2 = x - C2_X_L2;
    assign bit_addr_c22 = x_c2[4:2];    // scaling to 32x64
    
    assign char_addr_s102 = {3'b011, sec_10s};
    assign y_s10 = y - S10_Y_T2;
    assign row_addr_s102 = y_s10[5:2];   // scaling to 32x64
    assign x_s10 = x - S10_X_L2;
    assign bit_addr_s102 = x_s10[4:2];   // scaling to 32x64
    
    assign char_addr_s12 = {3'b011, sec_1s};
    assign y_s1 = y - S1_Y_T2;
    assign row_addr_s12 = y_s1[5:2];   // scaling to 32x64
    assign x_s1 = x - S1_X_L2;
    assign bit_addr_s12 = x_s1[4:2];   // scaling to 32x64

    // Minute sections assert signals;
    assign M1_on2 =  (M1_X_L2 <= x) && (x < M1_X_R2) &&
                    (M1_Y_T2 <= y) && (y < M1_Y_B2);                             
    
    // Colon 2 ROM assert signals
    assign C2_on2 = (C2_X_L2 <= x) && (x < C2_X_R2) &&
                   (C2_Y_T2 <= y) && (y < C2_Y_B2);
                  
    // Second sections assert signals
    assign S10_on2 = (S10_X_L2 <= x) && (x < S10_X_R2) &&
                    (S10_Y_T2 <= y) && (y < S10_Y_B2);
    assign S1_on2 =  (S1_X_L2 <= x) && (x < S1_X_R2) &&
                    (S1_Y_T2 <= y) && (y < S1_Y_B2);
        
    // Mux for ROM Addresses and RGB    
    always @ (posedge clk) begin
        time_rgb = 12'hFFF;
        
        //2nd clock
        if(M1_on2) begin
             char_addr2 = char_addr_m12;
             row_addr2 = row_addr_m12;
             bit_addr2 = bit_addr_m12;
             if(digit_bit2)
                 time_rgb = 12'hF00;     
         end
         else if(C2_on2) begin
             char_addr2 = char_addr_c22;
             row_addr2 = row_addr_c22;
             bit_addr2 = bit_addr_c22;
             if(digit_bit2)
                 time_rgb = 12'hF00;     
         end
         else if(S10_on2) begin
             char_addr2 = char_addr_s102;
             row_addr2 = row_addr_s102;
             bit_addr2 = bit_addr_s102;
             if(digit_bit2)
                 time_rgb = 12'hF00;     
         end
         else if(S1_on2) begin
             char_addr2 = char_addr_s12;
             row_addr2 = row_addr_s12;
             bit_addr2 = bit_addr_s12;
             if(digit_bit2)
                 time_rgb = 12'hF00;    
         end  
         else time_rgb = 12'hFFF;
    end    
    
    // ROM Interface    
    assign rom_addr2 = {char_addr2, row_addr2};
    assign digit_bit2 = digit_word2[~bit_addr2];       
                          
endmodule
