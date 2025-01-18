`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/18/2025 10:52:34 AM
// Design Name: 
// Module Name: W5500Driver
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


module W5500Driver(
    input i_clk,
    input i_rst,
    input i_spi_miso,
    output o_spi_mosi,
    output o_spi_clk,
    output o_spi_cs,
    output o_w5500_rst,
    input i_w5500_int,
    output [7:0] o_rx_data,
    output o_rx_valid,
    input [7:0] i_tx_data,
    input i_tx_valid,
    output o_tx_done
    );
endmodule
