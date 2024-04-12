`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/28 23:24:04
// Design Name: 
// Module Name: Flexible_clock
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


module Flexible_clock (input clk , [31:0] my_m_value, output reg clk_output = 0);    
   reg[31:0] count = 0;    
   always @ (posedge clk)
   begin
       count <= (count == my_m_value) ? 0 : count + 1;
       clk_output <= (count == 0) ? ~clk_output : clk_output;
   end
endmodule
