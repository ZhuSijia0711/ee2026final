`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/03 23:42:12
// Design Name: 
// Module Name: click_display
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


module click_display(
    input clk,          // 100MHz on Basys 3
    input reset,            // btnC
    input tick_hr,          // btnL
    input tick_min,         // btnR
    output hsync,       // to VGA connector
    output vsync,       // to VGA connector
    output [11:0] rgb,   // to DAC, to VGA connector
    output [15:0] led,
    inout PS2Clk,
    inout PS2Data
    );
    
    // Define grid parameters
    localparam GRID_WIDTH = 15; // Width of the grid (number of columns)
    localparam GRID_HEIGHT = 15; // Height of the grid (number of rows)
    localparam GRID_SPACING_X = 20; // Spacing between vertical grid lines
    localparam GRID_SPACING_Y = 20; // Spacing between horizontal grid lines
    localparam GRID_THICKNESS = 1; // Thickness of grid lines
    
    // Calculate starting position of the grid to place it at the left middle of the screen
    localparam GRID_START_X = 60; // Adjust as needed for the left padding
    localparam GRID_START_Y = 100;
    
    // signals
    wire [11:0] w_x, w_y;
    wire w_video_on, w_p_tick;
    reg [11:0] rgb_reg;
    wire [11:0] rgb_next_test;
    wire [11:0] rgb_next_board;
    wire [11:0] rgb_next_cursor;
    wire [11:0] rgb_next_chess_game;
    wire [11:0] rgb_next_black_win;
    wire [11:0] rgb_next_white_win;
    wire [11:0] rgb_next_draw;    
    wire [11:0] rgb_next_player;
    wire [11:0] rgb_word;
    wire [11:0] rgb_next;
    wire [11:0] rgb_next2;
    wire [11:0] rgb_next_control;
    wire [11:0] rgb_next_chess_replay;
    wire [11:0] rgb_next_control_replay;
    
    wire [11:0] mouse_x;
    wire [11:0] mouse_y;
    wire clicked;
    wire valid_click;
    
    wire is_grid;
    wire is_cursor;
    wire is_chess_game;
    wire is_chess_replay;
    wire is_control;
    wire is_control_replay;
    wire is_player_display;
    wire is_timer_display_black;
    wire is_timer_display_white;    
    wire st_g;
    wire b;
    
    wire [5:0] counter_black;
    wire [5:0] counter_white;
    
    wire black_min_1s;
    wire [3:0] black_sec_1s;
    wire [3:0] black_sec_10s;
    
    wire white_min_1s;
    wire [3:0] white_sec_1s;
    wire [3:0] white_sec_10s;
    
    wire [1:0] success;
    wire [7:0] step_to_replay;
    wire [7:0] step_number; 
    wire [3:0] x_coordinate;
    wire [3:0] y_coordinate;
    wire valid_click_white;
    wire valid_click_black;
    wire [1:0]mode;
    wire click_start;
    wire click_restart;
    wire click_quit;
    wire click_replay;
    reg color = 0;

    start_game sg(.clk(clk), .video_on(w_video_on), .x(w_x), .y(w_y), .rgb(rgb_word), .st_g(st_g)); 
     
    pixel_clk_gen pclk(
        .clk(clk),
        .video_on(w_video_on),
        .x(w_x),
        .y(w_y),
        .sec_1s(black_sec_1s),
        .sec_10s(black_sec_10s),
        .min_1s(black_min_1s),
        .time_rgb(rgb_next),
        .is_timer_display_black(is_timer_display_black)
    );
         
    pixel_clk_gen2 pclk2(
         .clk(clk),
         .video_on(w_video_on),
         .x(w_x),
         .y(w_y),
         .sec_1s(white_sec_1s),
         .sec_10s(white_sec_10s),
         .min_1s(white_min_1s),
         .time_rgb(rgb_next2),
         .is_timer_display_white(is_timer_display_white)
     );  
    
    // VGA Controller
    vga_controller vga(.clk_100MHz(clk), .reset(reset), .hsync(hsync), .vsync(vsync),
                       .video_on(w_video_on), .p_tick(w_p_tick), .x(w_x), .y(w_y));
    
    //text                   
    ascii_test at(.clk(clk), .video_on(w_video_on), .x(w_x), .y(w_y), .rgb(rgb_next_test));
                           
    //Black Win Text
    black_win_animation bwt(.clk(clk), .video_on(w_video_on), .x(w_x), .y(w_y), .rgb(rgb_next_black_win));
                           
    //White Win Text
    white_win_animation wwt(.clk(clk), .video_on(w_video_on), .x(w_x), .y(w_y), .rgb(rgb_next_white_win));
    
     //Draw Text
    draw_animation dt(.clk(clk), .video_on(w_video_on), .x(w_x), .y(w_y), .rgb(rgb_next_draw));
                           
    //Replay Text
    control_animation coa(.clk(clk), .video_on(w_video_on), .x(w_x), .y(w_y), .rgb(rgb_next_control), .is_control(is_control));
    
    replay_control_animation rcoa(.clk(clk), .video_on(w_video_on), .x(w_x), .y(w_y), .rgb(rgb_next_control_replay), .is_control(is_control_replay));
  
    //board
    board_animation ba (.clk(clk), .video_on(w_video_on), .x(w_x), .y(w_y), .rgb(rgb_next_board), 
    .x_in(mouse_x), .y_in(mouse_y), .clicked(clicked), .is_grid(is_grid));
    
    //Player display
    player_animation pa (.clk(clk), .video_on(w_video_on), .x(w_x), .y(w_y), .rgb(rgb_next_player), .is_player_display(is_player_display));
        
    //cursor
    cursor_animation ca (.clk(clk), .video_on(w_video_on), .x(w_x), .y(w_y), .step_to_replay(step_to_replay), .step_number(step_number), .rgb_cursor(rgb_next_cursor), .rgb_chess(rgb_next_chess_game),
    .PS2Clk(PS2Clk), .PS2Data(PS2Data), .x_out(mouse_x), .y_out(mouse_y),  .x_coordinate(x_coordinate), .y_coordinate(y_coordinate),
    .valid_click_black(valid_click_black), .valid_click_white(valid_click_white), .clicked(clicked), .is_cursor(is_cursor), .is_chess(is_chess_game), .mode(mode),
    .click_start(click_start), .click_restart(click_restart), .click_quit(click_quit), .click_replay(click_replay));

    game_logic main (.clk(clk), .color(color), .x(x_coordinate), .y(y_coordinate), .click_start(click_start), .click_restart(click_restart), .click_quit(click_quit), .click_replay(click_replay), .mode(mode), .success(success), .step_to_replay(step_to_replay), .step_number(step_number), .counter_black(counter_black), .counter_white(counter_white));     

    replay_control ra(.clk(clk), .video_on(w_video_on), .x(w_x), .y(w_y), .mode(mode), .step_to_replay(step_to_replay), .step_number(step_number), .rgb_chess(rgb_next_chess_replay), .is_chess(is_chess_replay));

    always @ (posedge clk) begin
        if (valid_click_white == 1) begin
            color = 1;
        end
        else if (valid_click_black == 1) begin
            color = 0;
        end
        if (mode == 2'b00 || mode == 2'b10) begin
            color = 1;
        end
    end

    // rgb buffer
    always @(posedge clk)
    begin
        if(w_p_tick)
        begin
            if (is_cursor)
            begin
                rgb_reg <= rgb_next_cursor; //display cursor
            end
            else if (mode == 2'b00)
            begin
                rgb_reg <= rgb_word; //display main page
            end
            else if (mode == 2'b01 && success == 2'b10)
            begin
                rgb_reg <= rgb_next_black_win; //display black win screen
            end
            else if (mode == 2'b01 && success == 2'b01)
            begin
                rgb_reg <= rgb_next_white_win; //display white win screen
            end
            else if (mode == 2'b01 && success == 2'b11)
            begin
                rgb_reg <= rgb_next_draw; //display draw screen
            end
            else if ((mode == 2'b01 || mode == 2'b10) && is_control)
            begin
                rgb_reg <= rgb_next_control; //display control bar on top
            end
            else if ((mode == 2'b01 || mode == 2'b10) && is_player_display)
            begin
                rgb_reg <= rgb_next_player; //display player A & B
            end
            else if ((mode == 2'b01 || mode == 2'b10) && is_timer_display_black)
            begin
                rgb_reg <= rgb_next; //display timers for player A & B
            end
            else if ((mode == 2'b01 || mode == 2'b10) && is_timer_display_white)
            begin
                rgb_reg <= rgb_next2; //display timers for player A & B
            end            
            else if ((mode == 2'b01 || mode == 2'b10) && is_chess_game)
            begin
                rgb_reg <= rgb_next_chess_game; //display chess
            end
            else if (mode == 2'b11 && is_chess_replay)
            begin
                rgb_reg <= rgb_next_chess_replay; //display chess
            end
            else if (mode == 2'b11 && is_control_replay) begin
                rgb_reg <= rgb_next_control_replay;
            end
            else if ((mode == 2'b01 || mode == 2'b10 || mode == 2'b11))
            begin
                rgb_reg <= rgb_next_board; //display board
            end
        end
    end
    
    assign rgb = rgb_reg;
    
    assign black_min_1s = (counter_black == 60) ? 1 : 0;
    assign white_min_1s = (counter_white == 60) ? 1 : 0;
    
    assign black_sec_10s = (counter_black == 60) ? 0 : counter_black / 10;
    assign black_sec_1s  = counter_black % 10;
    
    assign white_sec_10s = (counter_white == 60) ? 0 : counter_white / 10;
    assign white_sec_1s  = counter_white % 10;
    
    assign led[15:12] = step_to_replay[7:4];
    assign led[3:0] = step_to_replay[3:0];
    assign led[11:4] = step_number;
    
endmodule