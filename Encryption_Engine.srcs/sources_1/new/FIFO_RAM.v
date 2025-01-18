`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/18/2025 10:52:34 AM
// Design Name: 
// Module Name: FIFO_RAM
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


module FIFO_RAM(
    input i_clk,
    input i_rst,
    input  [7:0] i_wr_data,
    input i_wr_en,
    input i_rd_en,
    output [7:0] o_rd_data,
    output o_empty,
    output o_full
    );
endmodule
