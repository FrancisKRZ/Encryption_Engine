`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/18/2025 10:52:34 AM
// Design Name: 
// Module Name: SPIController
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


module SPIController(
    input i_clk,
    input i_rst,
    input  [7:0] i_data_in,
    input i_start,
    output [7:0] o_data_out,
    output o_done,
    output o_spi_mosi,
    input i_spi_miso,
    output o_spi_clk,
    output o_spi_cs
    );
endmodule
