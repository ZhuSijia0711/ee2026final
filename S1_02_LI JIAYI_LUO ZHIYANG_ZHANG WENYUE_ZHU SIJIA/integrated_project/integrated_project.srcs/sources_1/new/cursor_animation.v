module cursor_animation(
    input clk,
    input video_on,
    input [11:0] x, y,
    input [1:0] mode,
    inout PS2Clk,
    inout PS2Data,
    input [7:0]step_to_replay, 
    input [7:0]step_number,
    output reg [11:0] rgb_cursor,rgb_chess,
    output reg [11:0] x_out,
    output reg [11:0] y_out,
    output reg [3:0] x_coordinate, y_coordinate,
    output reg valid_click_black=0,
    output reg valid_click_white=0, 
    output clicked,
    output is_cursor,
    output reg is_chess,
    output reg click_start,
    output reg click_restart,
    output reg click_quit,
    output reg click_replay
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
    // Parameters for debounce timing
    localparam DEBOUNCE_TIME = 50000; // Adjust based on clock frequency and desired debounce duration
    localparam CLK_FREQ = 100_000_000; // Example: 100 MHz clock frequency
    // Calculation of debounce counts, assuming a 100MHz clock for a 10ms debounce time
    // DEBOUNCE_LIMIT determines how long the signal needs to be stable to consider the bounce settled
    localparam DEBOUNCE_LIMIT = (CLK_FREQ / 1000) * 10 / DEBOUNCE_TIME; 
        
    wire [9:0] xpos;wire [9:0] ypos;
    wire [3:0] zpos;
    wire left, middle, right, new_event;
    reg setx, sety, setmax_x, setmax_y = 0;
    reg [11:0] value = 0;
    reg [15:0] debounce_counter = 0; // 16-bit counter for debounce timing
    reg clicked_stable = 0; // Stable state of the clicked signal after debouncing
    reg clicked_last = 0; // Last state of the clicked signal for edge detection
    reg [11:0]center_x;
    reg [11:0]center_y;
    reg [11:0]dx;
    reg [11:0]dy;
    reg [3:0]i_replay;
    reg [3:0]j_replay;
    reg [7:0]step_count = 0;
    reg [3:0] cursor_bit_counter;
    reg cursor_bit_on;
    reg [11:0] cursor_x;
    reg [11:0] cursor_y;
    reg [14:0] position_overall [14:0];
    reg [14:0] position_black [14:0];
    reg [14:0] position_white [14:0];
    reg color=0;
    reg click_in_board =0;
    reg [3:0] i,j;
    reg valid_move;
    
    // Instantiate MouseCtl module
    MouseCtl unit_mouse
    (
        .clk(clk),
        .rst(0),
        .xpos(xpos),
        .ypos(ypos),
        .zpos(zpos),
        .left(left),
        .middle(middle),
        .right(right),
        .new_event(new_event),
        .value(value),
        .setx(setx),
        .sety(sety),
        .setmax_x(setmax_x),
        .setmax_y(setmax_y),
        .ps2_clk(PS2Clk),
        .ps2_data(PS2Data)
    );
    
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
    
    // Counter to control cursor animation rate
    always @(posedge clk) begin
        if (cursor_bit_counter == 10'b1111111111) // Assuming 100MHz clock and 500ms period
            cursor_bit_counter <= 0;
        else
            cursor_bit_counter <= cursor_bit_counter + 1;
    end

    // Determine if cursor should be on or off based on counter value
    always @(posedge clk) begin
        if (cursor_bit_counter < 10'b0101010101) // 50% duty cycle
            cursor_bit_on = 1'b1;
        else
            cursor_bit_on = 1'b0;
    end

    // Determine cursor position based on mouse coordinates
    always @ (posedge clk) begin
    
        if (mode == 2'b00 && clicked_stable && cursor_x >= 352 && cursor_x < 400 && cursor_y >= 224 && cursor_y < 240) begin
            click_replay <= 1;
        end
        else begin
            click_replay <= 0;
        end
        
        if (mode == 2'b01 && clicked_stable && cursor_x >= 232 && cursor_x < 288 && cursor_y >= 64 && cursor_y < 80) begin
            click_restart <= 1;
        end
        else begin
            click_restart <= 0;
        end
        
        if (mode == 2'b01 && clicked_stable && cursor_x >= 320 && cursor_x < 352 && cursor_y >= 64 && cursor_y < 80) begin
            click_quit <= 1;
        end
        else if (mode == 2'b11 && clicked_stable && cursor_x >= 320 && cursor_x < 352 && cursor_y >= 64 && cursor_y < 80) begin
            click_quit <= 1;
        end
        else begin
            click_quit <= 0;
        end
        
        if (mode == 2'b00 && clicked_stable && cursor_x >= 224 && cursor_x < 304 && cursor_y >= 224 && cursor_y < 240) begin
            click_start <= 1;
        end
        else begin
            click_start <= 0;
        end
    end

    always @ (posedge clk) begin
        if (video_on)
        begin
            cursor_x = xpos;
            cursor_y = ypos;
        end
        else
        begin
            // Set cursor off-screen when video is off
            cursor_x = 10'h3FF;
            cursor_y = 10'h3FF;
        end
    end

    always @(posedge clk) begin
        if (mode == 2'b10 || mode == 2'b00) begin
            color <= 0;
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
            
            position_overall[0] <= 15'd0;
            position_overall[1] <= 15'd0;
            position_overall[2] <= 15'd0;
            position_overall[3] <= 15'd0;
            position_overall[4] <= 15'd0;
            position_overall[5] <= 15'd0;
            position_overall[6] <= 15'd0;
            position_overall[7] <= 15'd0;
            position_overall[8] <= 15'd0;
            position_overall[9] <= 15'd0;
            position_overall[10] <= 15'd0;
            position_overall[11] <= 15'd0;
            position_overall[12] <= 15'd0;
            position_overall[13] <= 15'd0;
            position_overall[14] <= 15'd0; 
        end

        if (clicked != clicked_last) begin
            // Reset counter if clicked signal changes
            debounce_counter <= 0;
            clicked_last <= clicked;
        end else if (debounce_counter < DEBOUNCE_LIMIT) begin
            // Increment counter while clicked signal is stable
            debounce_counter <= debounce_counter + 1;
            if (debounce_counter == DEBOUNCE_LIMIT - 1) begin
                // Once the counter reaches the limit, consider the clicked signal stable
                clicked_stable <= clicked_last;
            end
        end

        if (mode==2'b01) begin
            if (clicked_stable && (cursor_x >= GRID_START_X-10) && (cursor_x < GRID_START_X + (GRID_WIDTH-1) * GRID_SPACING_X + 10) && 
                (cursor_y >= GRID_START_Y-10) && (cursor_y < GRID_START_Y + (GRID_HEIGHT-1) * GRID_SPACING_Y + 10)) begin
                click_in_board = 1;
                x_coordinate = (cursor_x - GRID_START_X + GRID_SPACING_X/2) / GRID_SPACING_X;
                y_coordinate = (cursor_y - GRID_START_Y + GRID_SPACING_Y/2) / GRID_SPACING_Y;
                valid_move = ~position_overall[x_coordinate][y_coordinate];
            end else begin
                click_in_board = 0;
                valid_move = 0; // Reset valid move
                // Resetting other LED states might not be necessary unless you specifically want to turn them off for each invalid click
            end
        
            if (valid_move == 1) begin
                position_overall[x_coordinate][y_coordinate]<=1;
                if (color == 0) begin // Black's turn
                    position_black[x_coordinate][y_coordinate] <= 1;
                    valid_click_black <= 1;
                    color <= 1;
                end else if (color == 1) begin // White's turn
                    position_white[x_coordinate][y_coordinate] <= 1;
                    valid_click_white <= 1;
                    color <= 0;
                end
            end else begin
                valid_click_black <= 0;
                valid_click_white <= 0;
            end 
        end 
        
        if (mode==2'b11) begin 
            i_replay = step_to_replay[7:4];
            j_replay = step_to_replay[3:0];
            if (step_count!= step_number) begin
                if (color == 0) begin // Black's turn
                    position_black[i_replay][j_replay] = 1;
                    color = 1;
                end else if (color == 1) begin // White's turn
                    position_white[i_replay][j_replay] = 1;
                    color = 0;
                end
                step_count = step_number;
            end    
        end else begin
            valid_click_black = 0;
            valid_click_white = 0;
        end
    
        //cursor display
        if (~video_on) begin
            rgb_cursor = 12'h000;      // blank
        end
        else if (x >= cursor_x && x < cursor_x + 5 && y >= cursor_y && y < cursor_y + 5) begin// Ensure cursor is within valid screen range
            if (click_in_board) 
            begin
                rgb_cursor = 12'hF00; //Blue click
                x_out = xpos;
                y_out = ypos;
            end else if (clicked) begin
                rgb_cursor = 12'h0F0; // green click
            end 
            else if (color==0) begin
                rgb_cursor = 12'h000;  // Black cursor
            end else if (color==1) begin 
                rgb_cursor = 12'hFFF;  // White cursor
            end
        end
        
        // chess display    
        if (~video_on) begin
            rgb_cursor = 12'h000;
        end
        else if ((x >= GRID_START_X-10) && (x < GRID_START_X + (GRID_WIDTH-1) * GRID_SPACING_X+10) && (y >= GRID_START_Y-10) && (y < GRID_START_Y + (GRID_HEIGHT-1) * GRID_SPACING_Y+10)) begin
            i = (x - GRID_START_X + GRID_SPACING_X/2) / GRID_SPACING_X;
            j = (y - GRID_START_Y + GRID_SPACING_Y/2) / GRID_SPACING_Y;
            center_x = i * GRID_SPACING_X + GRID_START_X;
            center_y = j * GRID_SPACING_Y + GRID_START_Y;
            dx = x > center_x ? x - center_x : center_x - x;
            dy = y > center_y ? y - center_y : center_y - y;
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
    
    //assign led = xpos + ypos;
    assign clicked = left;
    assign is_cursor = (x >= cursor_x) & (x < cursor_x + 5) & (y >= cursor_y) & (y < cursor_y + 5);
    
endmodule
