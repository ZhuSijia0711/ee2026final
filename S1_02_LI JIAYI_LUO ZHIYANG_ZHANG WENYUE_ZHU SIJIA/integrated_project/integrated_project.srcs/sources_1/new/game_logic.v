`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/04 00:08:42
// Design Name: 
// Module Name: game_logic
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


module game_logic(input clk, color, click_start, click_restart, click_quit, click_replay, [3:0]x, [3:0]y, output reg [1:0]mode, output reg [1:0]success = 0, output reg [7:0]step_to_replay = 0, 
output reg [7:0] step_number = 0, output reg [5:0]counter_black = 6'd60, output reg [5:0]counter_white = 6'd60);
//success == 2'b11: equal; success == 2'b01: black wins; success == 2'b10: white wins
//mode == 2'b00: quit(main_page); mode == 2'b01: start; mode == 2'b10: restart; mode == 2'b11: replay

reg [14:0] position_black [14:0];
reg [14:0] position_white [14:0];
reg [14:0] position_overall [14:0];
reg [7:0] record [224:0];
//225 steps at most, each have 8 bits, most significant 4 bits are x and the later 4 bits are y
//black first hence black takes even index, white takes odd index!! BLACK FIRST!!
reg [7:0] index = 0;
//index of rounds now
reg [8:0] total_time = 0;
reg [5:0] step_time = 0;
wire clk_1, clk_0p5;
reg [7:0]counter_0p5Hz = 0;
reg [31:0] success_counter = 0;
reg [31:0] counter_1s = 0;
reg [31:0] counter_1p5s = 0;

initial begin
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
    
    position_overall[0] = 15'd0;
    position_overall[1] = 15'd0;
    position_overall[2] = 15'd0;
    position_overall[3] = 15'd0;
    position_overall[4] = 15'd0;
    position_overall[5] = 15'd0;
    position_overall[6] = 15'd0;
    position_overall[7] = 15'd0;
    position_overall[8] = 15'd0;
    position_overall[9] = 15'd0;
    position_overall[10] = 15'd0;
    position_overall[11] = 15'd0;
    position_overall[12] = 15'd0;
    position_overall[13] = 15'd0;
    position_overall[14] = 15'd0; 
end

initial begin
    record[0] = 8'b0;
    record[1] = 8'b0;
    record[2] = 8'b0;
    record[3] = 8'b0;
    record[4] = 8'b0;
    record[5] = 8'b0;
    record[6] = 8'b0;
    record[7] = 8'b0;
    record[8] = 8'b0;
    record[9] = 8'b0;
    record[10] = 8'b0;
    record[11] = 8'b0;
    record[12] = 8'b0;
    record[13] = 8'b0;
    record[14] = 8'b0;
    record[15] = 8'b0;
    record[16] = 8'b0;
    record[17] = 8'b0;
    record[18] = 8'b0;
    record[19] = 8'b0;
    record[20] = 8'b0;
    record[21] = 8'b0;
    record[22] = 8'b0;
    record[23] = 8'b0;
    record[24] = 8'b0;
    record[25] = 8'b0;
    record[26] = 8'b0;
    record[27] = 8'b0;
    record[28] = 8'b0;
    record[29] = 8'b0;
    record[30] = 8'b0;
    record[31] = 8'b0;
    record[32] = 8'b0;
    record[33] = 8'b0;
    record[34] = 8'b0;
    record[35] = 8'b0;
    record[36] = 8'b0;
    record[37] = 8'b0;
    record[38] = 8'b0;
    record[39] = 8'b0;
    record[40] = 8'b0;
    record[41] = 8'b0;
    record[42] = 8'b0;
    record[43] = 8'b0;
    record[44] = 8'b0;
    record[45] = 8'b0;
    record[46] = 8'b0;    
    record[47] = 8'b0;
    record[48] = 8'b0;
    record[49] = 8'b0;
    record[50] = 8'b0;
    record[51] = 8'b0;
    record[52] = 8'b0;
    record[53] = 8'b0;
    record[54] = 8'b0;
    record[55] = 8'b0;
    record[56] = 8'b0;
    record[57] = 8'b0;
    record[58] = 8'b0;
    record[59] = 8'b0;
    record[60] = 8'b0;
    record[61] = 8'b0;
    record[62] = 8'b0;
    record[63] = 8'b0;
    record[64] = 8'b0;
    record[65] = 8'b0;
    record[66] = 8'b0;
    record[67] = 8'b0;
    record[68] = 8'b0;
    record[69] = 8'b0;
    record[70] = 8'b0;
    record[71] = 8'b0;
    record[72] = 8'b0;
    record[73] = 8'b0;
    record[74] = 8'b0;
    record[75] = 8'b0;
    record[76] = 8'b0;
    record[77] = 8'b0;
    record[78] = 8'b0; 
    record[79] = 8'b0;
    record[80] = 8'b0;
    record[81] = 8'b0;
    record[82] = 8'b0;
    record[83] = 8'b0;
    record[84] = 8'b0;
    record[85] = 8'b0;
    record[86] = 8'b0;
    record[87] = 8'b0;
    record[88] = 8'b0;
    record[89] = 8'b0;
    record[90] = 8'b0;
    record[91] = 8'b0;
    record[92] = 8'b0;
    record[93] = 8'b0;
    record[94] = 8'b0;
    record[95] = 8'b0;
    record[96] = 8'b0;
    record[97] = 8'b0;
    record[98] = 8'b0;
    record[99] = 8'b0;
    record[100] = 8'b0;
    record[101] = 8'b0;
    record[102] = 8'b0;
    record[103] = 8'b0;
    record[104] = 8'b0;
    record[105] = 8'b0;
    record[106] = 8'b0;
    record[107] = 8'b0;
    record[108] = 8'b0;
    record[109] = 8'b0;
    record[110] = 8'b0;
    record[111] = 8'b0;
    record[112] = 8'b0;
    record[113] = 8'b0;
    record[114] = 8'b0;
    record[115] = 8'b0;
    record[116] = 8'b0;
    record[117] = 8'b0;
    record[118] = 8'b0;
    record[119] = 8'b0;
    record[120] = 8'b0;
    record[121] = 8'b0;
    record[122] = 8'b0;
    record[123] = 8'b0;
    record[124] = 8'b0;
    record[125] = 8'b0;
    record[126] = 8'b0;
    record[127] = 8'b0;
    record[128] = 8'b0;
    record[129] = 8'b0;
    record[130] = 8'b0;
    record[131] = 8'b0;
    record[132] = 8'b0;
    record[133] = 8'b0;
    record[134] = 8'b0;
    record[135] = 8'b0;
    record[136] = 8'b0;
    record[137] = 8'b0;
    record[138] = 8'b0;
    record[139] = 8'b0;
    record[140] = 8'b0;
    record[141] = 8'b0;
    record[142] = 8'b0;
    record[143] = 8'b0;
    record[144] = 8'b0;
    record[145] = 8'b0;
    record[146] = 8'b0;
    record[147] = 8'b0;
    record[148] = 8'b0;
    record[149] = 8'b0;
    record[150] = 8'b0;
    record[151] = 8'b0;
    record[152] = 8'b0;
    record[153] = 8'b0;
    record[154] = 8'b0;
    record[155] = 8'b0;
    record[156] = 8'b0;
    record[157] = 8'b0;
    record[158] = 8'b0;
    record[159] = 8'b0;
    record[160] = 8'b0;
    record[161] = 8'b0;
    record[162] = 8'b0;
    record[163] = 8'b0;
    record[164] = 8'b0;
    record[165] = 8'b0;
    record[166] = 8'b0;
    record[167] = 8'b0;
    record[168] = 8'b0;
    record[169] = 8'b0;
    record[170] = 8'b0;
    record[171] = 8'b0; 
    record[172] = 8'b0;
    record[173] = 8'b0;
    record[174] = 8'b0;
    record[175] = 8'b0;
    record[176] = 8'b0;
    record[177] = 8'b0;
    record[178] = 8'b0;
    record[179] = 8'b0;
    record[180] = 8'b0;
    record[181] = 8'b0;
    record[182] = 8'b0;
    record[183] = 8'b0;
    record[184] = 8'b0;
    record[185] = 8'b0;
    record[186] = 8'b0;
    record[187] = 8'b0;
    record[188] = 8'b0;
    record[189] = 8'b0;
    record[190] = 8'b0;
    record[191] = 8'b0;
    record[192] = 8'b0;
    record[193] = 8'b0;
    record[194] = 8'b0;
    record[195] = 8'b0;
    record[196] = 8'b0;
    record[197] = 8'b0;
    record[198] = 8'b0;
    record[199] = 8'b0;
    record[200] = 8'b0;
    record[201] = 8'b0;
    record[202] = 8'b0;     
    record[203] = 8'b0;
    record[204] = 8'b0;
    record[205] = 8'b0;
    record[206] = 8'b0;
    record[207] = 8'b0;
    record[208] = 8'b0;
    record[209] = 8'b0;
    record[210] = 8'b0;
    record[211] = 8'b0;
    record[212] = 8'b0;
    record[213] = 8'b0;
    record[214] = 8'b0;
    record[215] = 8'b0;
    record[216] = 8'b0;
    record[217] = 8'b0;
    record[218] = 8'b0;
    record[219] = 8'b0;
    record[220] = 8'b0;
    record[221] = 8'b0;
    record[222] = 8'b0;
    record[223] = 8'b0;
    record[224] = 8'b0; 
end

Flexible_clock clk_divider_1 (.clk(clk), .my_m_value(32'd49999999), .clk_output(clk_1));
Flexible_clock clk_divider_0p5 (.clk(clk), .my_m_value(32'd99999999), .clk_output(clk_0p5));

always @ (posedge clk) begin
    if (mode == 2'b01) begin
    
        counter_1s <= (counter_1s == 99_999_999) ? 0 : counter_1s + 1;
        
        if (color == 0) begin
            counter_black <= 60;
            if (counter_1s == 0) begin
                counter_white <= (counter_white == 0) ? counter_white : (counter_white - 1);
            end
        end
        if (color == 1) begin
            counter_white <= 60;
            if (counter_1s == 0) begin
                counter_black <= (counter_black == 0) ? counter_black : (counter_black - 1);
            end
        end        
    end
    else begin
        counter_white <= 60;
        counter_black <= 60;
    end
    //every player has one minute per round, exceed 1 min will lead to success of the oponent
end

always @ (posedge clk_0p5) begin
    if (mode == 2'b11) begin
        counter_0p5Hz <= (counter_0p5Hz < index) ? counter_0p5Hz + 1 : counter_0p5Hz;
    end
    else begin
        counter_0p5Hz <= 0;
    end
end

always @ (posedge clk) begin
    if (mode == 2'b11) begin
        if (counter_0p5Hz < index) begin
            step_to_replay <= record[counter_0p5Hz];
            step_number <= counter_0p5Hz;
        end
        else begin
            step_to_replay <= step_to_replay;
            step_number <= step_number;
        end
    end
    else begin
        step_to_replay <= 0;
        step_number <= 0;
    end
end

always @ (posedge clk) begin
    counter_1p5s <= (counter_1p5s == 0) ? counter_1p5s : (counter_1p5s == 150_000_000 ? 0 : counter_1p5s + 1);
    
    if (counter_black == 0) begin
        success = 2'b01;
    end
    else if (counter_white == 0) begin
        success = 2'b10;
    end
        //mode transition
    if (mode == 2'b00 && click_start && counter_1p5s == 0) begin
        counter_1p5s <= counter_1p5s + 1;
    end
    else if (mode == 2'b01 && click_restart) begin
        mode = 2'b10;
    end
    else if (mode == 2'b10) begin
        mode = 2'b01;
    end
    else if (mode == 2'b01 && click_quit) begin
        mode = 2'b00;
    end
    else if (mode == 2'b01 && success != 2'b00) begin
        success_counter = (success_counter == 500_000_000) ? success_counter : success_counter + 1;
        mode = (success_counter == 500_000_000) ? 2'b00 : mode;
    end
    else if (mode == 2'b00 && click_replay) begin
        mode = 2'b11;
    end
    else if (mode == 2'b11 && click_quit) begin
        mode = 2'b00;
    end
    if(counter_1p5s == 150_000_000) begin
        mode = 2'b01;
        record[0] = 8'b0;
        record[1] = 8'b0;
        record[2] = 8'b0;
        record[3] = 8'b0;
        record[4] = 8'b0;
        record[5] = 8'b0;
        record[6] = 8'b0;
        record[7] = 8'b0;
        record[8] = 8'b0;
        record[9] = 8'b0;
        record[10] = 8'b0;
        record[11] = 8'b0;
        record[12] = 8'b0;
        record[13] = 8'b0;
        record[14] = 8'b0;
        record[15] = 8'b0;
        record[16] = 8'b0;
        record[17] = 8'b0;
        record[18] = 8'b0;
        record[19] = 8'b0;
        record[20] = 8'b0;
        record[21] = 8'b0;
        record[22] = 8'b0;
        record[23] = 8'b0;
        record[24] = 8'b0;
        record[25] = 8'b0;
        record[26] = 8'b0;
        record[27] = 8'b0;
        record[28] = 8'b0;
        record[29] = 8'b0;
        record[30] = 8'b0;
        record[31] = 8'b0;
        record[32] = 8'b0;
        record[33] = 8'b0;
        record[34] = 8'b0;
        record[35] = 8'b0;        
        record[36] = 8'b0;
        record[37] = 8'b0;
        record[38] = 8'b0;
        record[39] = 8'b0;
        record[40] = 8'b0;
        record[41] = 8'b0;
        record[42] = 8'b0;
        record[43] = 8'b0;
        record[44] = 8'b0;
        record[45] = 8'b0;
        record[46] = 8'b0;    
        record[47] = 8'b0;
        record[48] = 8'b0;
        record[49] = 8'b0;
        record[50] = 8'b0;
        record[51] = 8'b0;
        record[52] = 8'b0;
        record[53] = 8'b0;
        record[54] = 8'b0;
        record[55] = 8'b0;
        record[56] = 8'b0;
        record[57] = 8'b0;
        record[58] = 8'b0;
        record[59] = 8'b0;
        record[60] = 8'b0;
        record[61] = 8'b0;
        record[62] = 8'b0;
        record[63] = 8'b0;
        record[64] = 8'b0;
        record[65] = 8'b0;
        record[66] = 8'b0;
        record[67] = 8'b0;
        record[68] = 8'b0;
        record[69] = 8'b0;
        record[70] = 8'b0;
        record[71] = 8'b0;
        record[72] = 8'b0;
        record[73] = 8'b0;
        record[74] = 8'b0;
        record[75] = 8'b0;
        record[76] = 8'b0;
        record[77] = 8'b0;
        record[78] = 8'b0; 
        record[79] = 8'b0;
        record[80] = 8'b0;
        record[81] = 8'b0;
        record[82] = 8'b0;
        record[83] = 8'b0;
        record[84] = 8'b0;
        record[85] = 8'b0;
        record[86] = 8'b0;
        record[87] = 8'b0;
        record[88] = 8'b0;
        record[89] = 8'b0;
        record[90] = 8'b0;
        record[91] = 8'b0;
        record[92] = 8'b0;
        record[93] = 8'b0;
        record[94] = 8'b0;
        record[95] = 8'b0;
        record[96] = 8'b0;
        record[97] = 8'b0;
        record[98] = 8'b0;
        record[99] = 8'b0;
        record[100] = 8'b0;
        record[101] = 8'b0;
        record[102] = 8'b0;
        record[103] = 8'b0;
        record[104] = 8'b0;
        record[105] = 8'b0;
        record[106] = 8'b0;
        record[107] = 8'b0;
        record[108] = 8'b0;
        record[109] = 8'b0;
        record[110] = 8'b0;
        record[111] = 8'b0;
        record[112] = 8'b0;
        record[113] = 8'b0;
        record[114] = 8'b0;
        record[115] = 8'b0;
        record[116] = 8'b0;
        record[117] = 8'b0;
        record[118] = 8'b0;
        record[119] = 8'b0;
        record[120] = 8'b0;
        record[121] = 8'b0;
        record[122] = 8'b0;
        record[123] = 8'b0;
        record[124] = 8'b0;
        record[125] = 8'b0;
        record[126] = 8'b0;
        record[127] = 8'b0;
        record[128] = 8'b0;
        record[129] = 8'b0;
        record[130] = 8'b0;
        record[131] = 8'b0;
        record[132] = 8'b0;
        record[133] = 8'b0;
        record[134] = 8'b0;
        record[135] = 8'b0;
        record[136] = 8'b0;
        record[137] = 8'b0;
        record[138] = 8'b0;
        record[139] = 8'b0;
        record[140] = 8'b0;
        record[141] = 8'b0;
        record[142] = 8'b0;
        record[143] = 8'b0;
        record[144] = 8'b0;
        record[145] = 8'b0;
        record[146] = 8'b0;
        record[147] = 8'b0;
        record[148] = 8'b0;
        record[149] = 8'b0;
        record[150] = 8'b0;
        record[151] = 8'b0;
        record[152] = 8'b0;
        record[153] = 8'b0;
        record[154] = 8'b0;
        record[155] = 8'b0;
        record[156] = 8'b0;
        record[157] = 8'b0;
        record[158] = 8'b0;
        record[159] = 8'b0;
        record[160] = 8'b0;
        record[161] = 8'b0;
        record[162] = 8'b0;
        record[163] = 8'b0;
        record[164] = 8'b0;
        record[165] = 8'b0;
        record[166] = 8'b0;
        record[167] = 8'b0;
        record[168] = 8'b0;
        record[169] = 8'b0;
        record[170] = 8'b0;
        record[171] = 8'b0; 
        record[172] = 8'b0;
        record[173] = 8'b0;
        record[174] = 8'b0;
        record[175] = 8'b0;
        record[176] = 8'b0;
        record[177] = 8'b0;
        record[178] = 8'b0;
        record[179] = 8'b0;
        record[180] = 8'b0;
        record[181] = 8'b0;
        record[182] = 8'b0;
        record[183] = 8'b0;
        record[184] = 8'b0;
        record[185] = 8'b0;
        record[186] = 8'b0;
        record[187] = 8'b0;
        record[188] = 8'b0;
        record[189] = 8'b0;
        record[190] = 8'b0;
        record[191] = 8'b0;
        record[192] = 8'b0;
        record[193] = 8'b0;
        record[194] = 8'b0;
        record[195] = 8'b0;
        record[196] = 8'b0;
        record[197] = 8'b0;
        record[198] = 8'b0;
        record[199] = 8'b0;
        record[200] = 8'b0;
        record[201] = 8'b0;
        record[202] = 8'b0;     
        record[203] = 8'b0;
        record[204] = 8'b0;
        record[205] = 8'b0;
        record[206] = 8'b0;
        record[207] = 8'b0;
        record[208] = 8'b0;
        record[209] = 8'b0;
        record[210] = 8'b0;
        record[211] = 8'b0;
        record[212] = 8'b0;
        record[213] = 8'b0;
        record[214] = 8'b0;
        record[215] = 8'b0;
        record[216] = 8'b0;
        record[217] = 8'b0;
        record[218] = 8'b0;
        record[219] = 8'b0;
        record[220] = 8'b0;
        record[221] = 8'b0;
        record[222] = 8'b0;
        record[223] = 8'b0;
        record[224] = 8'b0;
        index = 0;
    end
    

    
    if (mode == 2'b01) begin
        if (position_overall[x][y] == 0) begin
            record [index] <= {x,y}; 
            index <= index + 1;
            if (color == 0) begin
                position_black[x][y] = 1;
                if (x <= 10 && x >= 0 && position_black[x][y] == 1 && position_black[x+1][y] == 1 && position_black[x+2][y] == 1 && position_black[x+3][y] == 1 && position_black[x+4][y] == 1) begin
                    success = 2'b01;
                end
                else if (x <= 11 && x >= 1 && position_black[x-1][y] == 1 && position_black[x][y] == 1 && position_black[x+1][y] == 1 && position_black[x+2][y] == 1 && position_black[x+3][y] == 1) begin
                    success = 2'b01;
                end
                else if (x <= 12 && x >= 2 && position_black[x-2][y] == 1 && position_black[x-1][y] == 1 && position_black[x][y] == 1 && position_black[x+1][y] == 1 && position_black[x+2][y] == 1) begin
                    success = 2'b01;
                end
                else if (x <= 13 && x >= 3 && position_black[x-3][y] == 1 && position_black[x-2][y] == 1 && position_black[x-1][y] == 1 && position_black[x][y] == 1 && position_black[x+1][y] == 1) begin
                    success = 2'b01;
                end
                else if (x <= 14 && x >= 4 && position_black[x-4][y] == 1 && position_black[x-3][y] == 1 && position_black[x-2][y] == 1 && position_black[x-1][y] == 1 && position_black[x][y] == 1) begin
                    success = 2'b01;
                end
                else if (y <= 10 && y >= 0 && position_black[x][y] == 1 && position_black[x][y+1] == 1 && position_black[x][y+2] == 1 && position_black[x][y+3] == 1 && position_black[x][y+4] == 1) begin
                    success = 2'b01;
                end
                else if (y <= 11 && y >= 1 && position_black[x][y-1] == 1 && position_black[x][y] == 1 && position_black[x][y+1] == 1 && position_black[x][y+2] == 1 && position_black[x][y+3] == 1) begin
                    success = 2'b01;
                end
                else if (y <= 12 && y >= 2 && position_black[x][y-2] == 1 && position_black[x][y-1] == 1 && position_black[x][y] == 1 && position_black[x][y+1] == 1 && position_black[x][y+2] == 1) begin
                    success = 2'b01;
                end
                else if (y <= 13 && y >= 3 && position_black[x][y-3] == 1 && position_black[x][y-2] == 1 && position_black[x][y-1] == 1 && position_black[x][y] == 1 && position_black[x][y+1] == 1) begin
                    success = 2'b01;
                end
                else if (y <= 14 && y >= 4 && position_black[x][y-4] == 1 && position_black[x][y-3] == 1 && position_black[x][y-2] == 1 && position_black[x][y-1] == 1 && position_black[x][y] == 1) begin
                    success = 2'b01;
                end      
                else if (x <= 10 && x >= 0 && y <= 10 && y >= 0 && position_black[x][y] == 1 && position_black[x+1][y+1] == 1 && position_black[x+2][y+2] == 1 && position_black[x+3][y+3] == 1 && position_black[x+4][y+4] == 1) begin
                    success = 2'b01;
                end
                else if (x <= 11 && x >= 1 && y <= 11 && y >= 1 && position_black[x-1][y-1] == 1 && position_black[x][y] == 1 && position_black[x+1][y+1] == 1 && position_black[x+2][y+2] == 1 && position_black[x+3][y+3] == 1) begin
                    success = 2'b01;
                end
                else if (x <= 12 && x >= 2 && y <= 12 && y >= 2 && position_black[x-2][y-2] == 1 && position_black[x-1][y-1] == 1 && position_black[x][y] == 1 && position_black[x+1][y+1] == 1 && position_black[x+2][y+2] == 1) begin
                    success = 2'b01;
                end
                else if (x <= 13 && x >= 3 && y <= 13 && y >= 3 && position_black[x-3][y-3] == 1 && position_black[x-2][y-2] == 1 && position_black[x-1][y-1] == 1 && position_black[x][y] == 1 && position_black[x+1][y+1] == 1) begin
                    success = 2'b01;
                end
                else if (x <= 14 && x >= 4 && y <= 14 && y >= 4 && position_black[x-4][y-4] == 1 && position_black[x-3][y-3] == 1 && position_black[x-2][y-2] == 1 && position_black[x-1][y-1] == 1 && position_black[x][y] == 1) begin
                    success = 2'b01;
                end 
                else if (x <= 10 && x >= 0 && y <= 14 && y >= 4 && position_black[x][y] == 1 && position_black[x+1][y-1] == 1 && position_black[x+2][y-2] == 1 && position_black[x+3][y-3] == 1 && position_black[x+4][y-4] == 1) begin
                    success = 2'b01;
                end
                else if (x <= 11 && x >= 1 && y <= 13 && y >= 3 && position_black[x-1][y+1] == 1 && position_black[x][y] == 1 && position_black[x+1][y-1] == 1 && position_black[x+2][y-2] == 1 && position_black[x+3][y-3] == 1) begin
                    success = 2'b01;
                end
                else if (x <= 12 && x >= 2 && y <= 12 && y >= 2 && position_black[x-2][y+2] == 1 && position_black[x-1][y+1] == 1 && position_black[x][y] == 1 && position_black[x+1][y-1] == 1 && position_black[x+2][y-2] == 1) begin
                    success = 2'b01;
                end
                else if (x <= 13 && x >= 3 && y <= 11 && y >= 1 && position_black[x-3][y+3] == 1 && position_black[x-2][y+2] == 1 && position_black[x-1][y+1] == 1 && position_black[x][y] == 1 && position_black[x+1][y-1] == 1) begin
                    success = 2'b01;
                end
                else if (x <= 14 && x >= 4 && y <= 10 && y >= 0 && position_black[x-4][y+4] == 1 && position_black[x-3][y+3] == 1 && position_black[x-2][y+2] == 1 && position_black[x-1][y+1] == 1 && position_black[x][y] == 1) begin
                    success = 2'b01;
                end
            end
            else begin
                position_white[x][y] = 1;
                if (x <= 10 && x >= 0 && position_white[x][y] == 1 && position_white[x+1][y] == 1 && position_white[x+2][y] == 1 && position_white[x+3][y] == 1 && position_white[x+4][y] == 1) begin
                    success =  2'b10;
                end
                else if (x <= 11 && x >= 1 && position_white[x-1][y] == 1 && position_white[x][y] == 1 && position_white[x+1][y] == 1 && position_white[x+2][y] == 1 && position_white[x+3][y] == 1) begin
                    success = 2'b10;
                end
                else if (x <= 12 && x >= 2 && position_white[x-2][y] == 1 && position_white[x-1][y] == 1 && position_white[x][y] == 1 && position_white[x+1][y] == 1 && position_white[x+2][y] == 1) begin
                    success = 2'b10;
                end
                else if (x <= 13 && x >= 3 && position_white[x-3][y] == 1 && position_white[x-2][y] == 1 && position_white[x-1][y] == 1 && position_white[x][y] == 1 && position_white[x+1][y] == 1) begin
                    success = 2'b10;
                end
                else if (x <= 14 && x >= 4 && position_white[x-4][y] == 1 && position_white[x-3][y] == 1 && position_white[x-2][y] == 1 && position_white[x-1][y] == 1 && position_white[x][y] == 1) begin
                    success = 2'b10;
                end          
                else if (y <= 10 && y >= 0 && position_white[x][y] == 1 && position_white[x][y+1] == 1 && position_white[x][y+2] == 1 && position_white[x][y+3] == 1 && position_white[x][y+4] == 1) begin
                    success = 2'b10;
                end
                else if (y <= 11 && y >= 1 && position_white[x][y-1] == 1 && position_white[x][y] == 1 && position_white[x][y+1] == 1 && position_white[x][y+2] == 1 && position_white[x][y+3] == 1) begin
                    success = 2'b10;
                end
                else if (y <= 12 && y >= 2 && position_white[x][y-2] == 1 && position_white[x][y-1] == 1 && position_white[x][y] == 1 && position_white[x][y+1] == 1 && position_white[x][y+2] == 1) begin
                    success = 2'b10;
                end
                else if (y <= 13 && y >= 3 && position_white[x][y-3] == 1 && position_white[x][y-2] == 1 && position_white[x][y-1] == 1 && position_white[x][y] == 1 && position_white[x][y+1] == 1) begin
                    success = 2'b10;
                end
                else if (y <= 14 && y >= 4 && position_white[x][y-4] == 1 && position_white[x][y-3] == 1 && position_white[x][y-2] == 1 && position_white[x][y-1] == 1 && position_white[x][y] == 1) begin
                    success = 2'b10;
                end                   
                else if (x <= 10 && x >= 0 && y <= 10 && y >= 0 && position_white[x][y] == 1 && position_white[x+1][y+1] == 1 && position_white[x+2][y+2] == 1 && position_white[x+3][y+3] == 1 && position_white[x+4][y+4] == 1) begin
                    success = 2'b10;
                end
                else if (x <= 11 && x >= 1 && y <= 11 && y >= 1 && position_white[x-1][y-1] == 1 && position_white[x][y] == 1 && position_white[x+1][y+1] == 1 && position_white[x+2][y+2] == 1 && position_white[x+3][y+3] == 1) begin
                    success = 2'b10;
                end
                else if (x <= 12 && x >= 2 && y <= 12 && y >= 2 && position_white[x-2][y-2] == 1 && position_white[x-1][y-1] == 1 && position_white[x][y] == 1 && position_white[x+1][y+1] == 1 && position_white[x+2][y+2] == 1) begin
                    success = 2'b10;
                end
                else if (x <= 13 && x >= 3 && y <= 13 && y >= 3 && position_white[x-3][y-3] == 1 && position_white[x-2][y-2] == 1 && position_white[x-1][y-1] == 1 && position_white[x][y] == 1 && position_white[x+1][y+1] == 1) begin
                    success = 2'b10;
                end
                else if (x <= 14 && x >= 4 && y <= 14 && y >= 4 && position_white[x-4][y-4] == 1 && position_white[x-3][y-3] == 1 && position_white[x-2][y-2] == 1 && position_white[x-1][y-1] == 1 && position_white[x][y] == 1) begin
                    success = 2'b10;
                end 
                else if (x <= 10 && x >= 0 && y <= 14 && y >= 4 && position_white[x][y] == 1 && position_white[x+1][y-1] == 1 && position_white[x+2][y-2] == 1 && position_white[x+3][y-3] == 1 && position_white[x+4][y-4] == 1) begin
                    success = 2'b10;
                end
                else if (x <= 11 && x >= 1 && y <= 13 && y >= 3 && position_white[x-1][y+1] == 1 && position_white[x][y] == 1 && position_white[x+1][y-1] == 1 && position_white[x+2][y-2] == 1 && position_white[x+3][y-3] == 1) begin
                    success = 2'b10;
                end
                else if (x <= 12 && x >= 2 && y <= 12 && y >= 2 && position_white[x-2][y+2] == 1 && position_white[x-1][y+1] == 1 && position_white[x][y] == 1 && position_white[x+1][y-1] == 1 && position_white[x+2][y-2] == 1) begin
                    success = 2'b10;
                end
                else if (x <= 13 && x >= 3 && y <= 11 && y >= 1 && position_white[x-3][y+3] == 1 && position_white[x-2][y+2] == 1 && position_white[x-1][y+1] == 1 && position_white[x][y] == 1 && position_white[x+1][y-1] == 1) begin
                    success = 2'b10;
                end
                else if (x <= 14 && x >= 4 && y <= 10 && y >= 0 && position_white[x-4][y+4] == 1 && position_white[x-3][y+3] == 1 && position_white[x-2][y+2] == 1 && position_white[x-1][y+1] == 1 && position_white[x][y] == 1) begin
                    success = 2'b10;
                end 
            end
            position_overall[x][y] = 1;
        end
        else if (position_overall[0] == 15'b111111111111111 &&
        position_overall[1] == 15'b111111111111111 && 
        position_overall[2] == 15'b111111111111111 && 
        position_overall[3] == 15'b111111111111111 && 
        position_overall[4] == 15'b111111111111111 && 
        position_overall[5] == 15'b111111111111111 && 
        position_overall[6] == 15'b111111111111111 && 
        position_overall[7] == 15'b111111111111111 && 
        position_overall[8] == 15'b111111111111111 && 
        position_overall[9] == 15'b111111111111111 &&
        position_overall[10] == 15'b111111111111111 && 
        position_overall[11] == 15'b111111111111111 && 
        position_overall[12] == 15'b111111111111111 && 
        position_overall[13] == 15'b111111111111111 && 
        position_overall[14] == 15'b111111111111111 &&
        success == 2'b00
        ) begin
            success = 2'b11;
        end
    end
    else if (mode == 2'b10) begin
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
    
        position_overall[0] = 15'd0;
        position_overall[1] = 15'd0;
        position_overall[2] = 15'd0;
        position_overall[3] = 15'd0;
        position_overall[4] = 15'd0;
        position_overall[5] = 15'd0;
        position_overall[6] = 15'd0;
        position_overall[7] = 15'd0;
        position_overall[8] = 15'd0;
        position_overall[9] = 15'd0;
        position_overall[10] = 15'd0;
        position_overall[11] = 15'd0;
        position_overall[12] = 15'd0;
        position_overall[13] = 15'd0;
        position_overall[14] = 15'd0; 
        
        record[0] = 8'b0;
        record[1] = 8'b0;
        record[2] = 8'b0;
        record[3] = 8'b0;
        record[4] = 8'b0;
        record[5] = 8'b0;
        record[6] = 8'b0;
        record[7] = 8'b0;
        record[8] = 8'b0;
        record[9] = 8'b0;
        record[10] = 8'b0;
        record[11] = 8'b0;
        record[12] = 8'b0;
        record[13] = 8'b0;
        record[14] = 8'b0;
        record[15] = 8'b0;
        record[16] = 8'b0;
        record[17] = 8'b0;
        record[18] = 8'b0;
        record[19] = 8'b0;
        record[20] = 8'b0;
        record[21] = 8'b0;
        record[22] = 8'b0;
        record[23] = 8'b0;
        record[24] = 8'b0;
        record[25] = 8'b0;
        record[26] = 8'b0;
        record[27] = 8'b0;
        record[28] = 8'b0;
        record[29] = 8'b0;
        record[30] = 8'b0;
        record[31] = 8'b0;
        record[32] = 8'b0;
        record[33] = 8'b0;
        record[34] = 8'b0;
        record[35] = 8'b0;        
        record[36] = 8'b0;
        record[37] = 8'b0;
        record[38] = 8'b0;
        record[39] = 8'b0;
        record[40] = 8'b0;
        record[41] = 8'b0;
        record[42] = 8'b0;
        record[43] = 8'b0;
        record[44] = 8'b0;
        record[45] = 8'b0;
        record[46] = 8'b0;    
        record[47] = 8'b0;
        record[48] = 8'b0;
        record[49] = 8'b0;
        record[50] = 8'b0;
        record[51] = 8'b0;
        record[52] = 8'b0;
        record[53] = 8'b0;
        record[54] = 8'b0;
        record[55] = 8'b0;
        record[56] = 8'b0;
        record[57] = 8'b0;
        record[58] = 8'b0;
        record[59] = 8'b0;
        record[60] = 8'b0;
        record[61] = 8'b0;
        record[62] = 8'b0;
        record[63] = 8'b0;
        record[64] = 8'b0;
        record[65] = 8'b0;
        record[66] = 8'b0;
        record[67] = 8'b0;
        record[68] = 8'b0;
        record[69] = 8'b0;
        record[70] = 8'b0;
        record[71] = 8'b0;
        record[72] = 8'b0;
        record[73] = 8'b0;
        record[74] = 8'b0;
        record[75] = 8'b0;
        record[76] = 8'b0;
        record[77] = 8'b0;
        record[78] = 8'b0; 
        record[79] = 8'b0;
        record[80] = 8'b0;
        record[81] = 8'b0;
        record[82] = 8'b0;
        record[83] = 8'b0;
        record[84] = 8'b0;
        record[85] = 8'b0;
        record[86] = 8'b0;
        record[87] = 8'b0;
        record[88] = 8'b0;
        record[89] = 8'b0;
        record[90] = 8'b0;
        record[91] = 8'b0;
        record[92] = 8'b0;
        record[93] = 8'b0;
        record[94] = 8'b0;
        record[95] = 8'b0;
        record[96] = 8'b0;
        record[97] = 8'b0;
        record[98] = 8'b0;
        record[99] = 8'b0;
        record[100] = 8'b0;
        record[101] = 8'b0;
        record[102] = 8'b0;
        record[103] = 8'b0;
        record[104] = 8'b0;
        record[105] = 8'b0;
        record[106] = 8'b0;
        record[107] = 8'b0;
        record[108] = 8'b0;
        record[109] = 8'b0;
        record[110] = 8'b0;
        record[111] = 8'b0;
        record[112] = 8'b0;
        record[113] = 8'b0;
        record[114] = 8'b0;
        record[115] = 8'b0;
        record[116] = 8'b0;
        record[117] = 8'b0;
        record[118] = 8'b0;
        record[119] = 8'b0;
        record[120] = 8'b0;
        record[121] = 8'b0;
        record[122] = 8'b0;
        record[123] = 8'b0;
        record[124] = 8'b0;
        record[125] = 8'b0;
        record[126] = 8'b0;
        record[127] = 8'b0;
        record[128] = 8'b0;
        record[129] = 8'b0;
        record[130] = 8'b0;
        record[131] = 8'b0;
        record[132] = 8'b0;
        record[133] = 8'b0;
        record[134] = 8'b0;
        record[135] = 8'b0;
        record[136] = 8'b0;
        record[137] = 8'b0;
        record[138] = 8'b0;
        record[139] = 8'b0;
        record[140] = 8'b0;
        record[141] = 8'b0;
        record[142] = 8'b0;
        record[143] = 8'b0;
        record[144] = 8'b0;
        record[145] = 8'b0;
        record[146] = 8'b0;
        record[147] = 8'b0;
        record[148] = 8'b0;
        record[149] = 8'b0;
        record[150] = 8'b0;
        record[151] = 8'b0;
        record[152] = 8'b0;
        record[153] = 8'b0;
        record[154] = 8'b0;
        record[155] = 8'b0;
        record[156] = 8'b0;
        record[157] = 8'b0;
        record[158] = 8'b0;
        record[159] = 8'b0;
        record[160] = 8'b0;
        record[161] = 8'b0;
        record[162] = 8'b0;
        record[163] = 8'b0;
        record[164] = 8'b0;
        record[165] = 8'b0;
        record[166] = 8'b0;
        record[167] = 8'b0;
        record[168] = 8'b0;
        record[169] = 8'b0;
        record[170] = 8'b0;
        record[171] = 8'b0; 
        record[172] = 8'b0;
        record[173] = 8'b0;
        record[174] = 8'b0;
        record[175] = 8'b0;
        record[176] = 8'b0;
        record[177] = 8'b0;
        record[178] = 8'b0;
        record[179] = 8'b0;
        record[180] = 8'b0;
        record[181] = 8'b0;
        record[182] = 8'b0;
        record[183] = 8'b0;
        record[184] = 8'b0;
        record[185] = 8'b0;
        record[186] = 8'b0;
        record[187] = 8'b0;
        record[188] = 8'b0;
        record[189] = 8'b0;
        record[190] = 8'b0;
        record[191] = 8'b0;
        record[192] = 8'b0;
        record[193] = 8'b0;
        record[194] = 8'b0;
        record[195] = 8'b0;
        record[196] = 8'b0;
        record[197] = 8'b0;
        record[198] = 8'b0;
        record[199] = 8'b0;
        record[200] = 8'b0;
        record[201] = 8'b0;
        record[202] = 8'b0;     
        record[203] = 8'b0;
        record[204] = 8'b0;
        record[205] = 8'b0;
        record[206] = 8'b0;
        record[207] = 8'b0;
        record[208] = 8'b0;
        record[209] = 8'b0;
        record[210] = 8'b0;
        record[211] = 8'b0;
        record[212] = 8'b0;
        record[213] = 8'b0;
        record[214] = 8'b0;
        record[215] = 8'b0;
        record[216] = 8'b0;
        record[217] = 8'b0;
        record[218] = 8'b0;
        record[219] = 8'b0;
        record[220] = 8'b0;
        record[221] = 8'b0;
        record[222] = 8'b0;
        record[223] = 8'b0;
        record[224] = 8'b0;
        index = 0;
        
        success = 2'b00;
        success_counter = 0;
    end
    else if (mode == 2'b00) begin
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

        position_overall[0] = 15'd0;
        position_overall[1] = 15'd0;
        position_overall[2] = 15'd0;
        position_overall[3] = 15'd0;
        position_overall[4] = 15'd0;
        position_overall[5] = 15'd0;
        position_overall[6] = 15'd0;
        position_overall[7] = 15'd0;
        position_overall[8] = 15'd0;
        position_overall[9] = 15'd0;
        position_overall[10] = 15'd0;
        position_overall[11] = 15'd0;
        position_overall[12] = 15'd0;
        position_overall[13] = 15'd0;
        position_overall[14] = 15'd0;
        
        success = 2'b00;
        success_counter = 0;         
    end
end
endmodule
