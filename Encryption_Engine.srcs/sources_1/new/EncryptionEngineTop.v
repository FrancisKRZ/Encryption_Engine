`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Penguin
// 
// Create Date: 01/18/2025 10:52:34 AM
// Design Name: CMEC
// Module Name: EncryptionEngineTop
// Project Name: Encryption Engine
// Target Devices: Basys 3 Artix-7
// Tool Versions: 2024.1
// Description: Top Level Design:

//	Encryption Engine: 
//		(inouts <ethernet module pins>, 
//		input clk, input reset)
//	
//		Instantiates:
//			W5500 Ethernet Module Driver w/ Parameters
//			
//			FIFO-RAM Module
//			
//			Encryption Select (Inputs: Encryption Mode, Data):
//				- Encrypt Function
//				- Decrypt Function
//				
//				Outputs (Encrypted Data or Decrypted Data)
//				
//
//External Files:	
//	W5500 Ethernet Module
//	
//	FIFO-RAM Module
//	
// 
// Dependencies: N/A
// 
// Revision 1.01 - ENCRYPTION ENGINE > FIFO_RAM > FIFO IP > SPI CONTROLLER > W5500 DRIVER
// Additional Comments:
//  PHYSICAL PINOUTS
// 	MOSI -> JA1	Orange
// 	MISO -> JA2	Brown
//	SCLK -> JA3	Yellow
//	CS   -> JA4	Grey
//
//	RST  -> JA7	Green
//	INT  -> JA8	Purple
//////////////////////////////////////////////////////////////////////////////////


/*
________________________________________________________________________________________
W5500 Port Connections:

	MOSI -> JA1	
 	MISO -> JA2	
	SCLK -> JA3	
	CS   -> JA4
		
    VCC  -> JA5
    GND  -> JA6
	
	RST  -> JA7	
	INT  -> JA8	
	
________________________________________________________________________________________
*/


module EncryptionEngineTop #(
    parameter KEY_SIZE = 128, 
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 256
)(
    input i_clk,                       // System clock
    input i_rst,                       // Reset signal
    input i_spi_miso,                  // SPI MISO (Master In Slave Out)
    output o_spi_mosi,                 // SPI MOSI (Master Out Slave In)
    output o_spi_clk,                  // SPI Clock
    output o_spi_cs,                   // SPI Chip Select
    output o_w5500_rst,                // Reset for W5500
    input i_w5500_int,                 // Interrupt from W5500
    input [KEY_SIZE-1:0] i_key,        // 128-bit encryption key
    output [DATA_WIDTH-1:0] o_encrypted_data, // Output encrypted data
    input i_start,                     // Start signal for encryption
    output o_done                      // Done signal indicating encryption completion
);

    // Internal signals for SPI and FIFO
    wire [DATA_WIDTH-1:0] spi_data_out;        // Data received from SPI
    wire spi_done;                             // SPI transfer complete signal
    wire fifo_wr_en;                           // FIFO write enable
    wire fifo_rd_en;                           // FIFO read enable
    wire fifo_empty;                           // FIFO empty flag
    wire fifo_full;                            // FIFO full flag
    wire [DATA_WIDTH-1:0] fifo_data_out;       // Data read from FIFO
    wire [DATA_WIDTH-1:0] encrypted_data_out;  // Data from the encryption engine
    wire encryption_done;                      // Encryption completion signal
    wire [$clog2(DEPTH)-1:0] fifo_count;       // FIFO count

    // SPI Controller Instance
    SPIController #(
        .DATA_WIDTH(DATA_WIDTH),
        .CPOL(0),   // Adjust as needed
        .CPHA(0)    // Adjust as needed
    ) spi_ctrl (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_data_in(8'h00),  // No data sent to SPI in this setup
        .i_start(i_start),
        .o_data_out(spi_data_out),
        .o_done(spi_done),
        .o_spi_mosi(o_spi_mosi),
        .i_spi_miso(i_spi_miso),
        .o_spi_clk(o_spi_clk),
        .o_spi_cs(o_spi_cs),
        .i_clk_div(8'd4),  // SPI clock divider, parameterize if needed
        .o_busy()          // Optional signal, leave unconnected if not needed
    );

    // FIFO RAM Instance
    FIFO_RAM #(
        .WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) fifo_inst (
        .i_clk(i_clk),
        .i_rst_n(!i_rst),          // Active-low reset
        .i_wr_data(spi_data_out),  // Data received from SPI
        .i_wr_en(spi_done),        // Write when SPI transaction is complete
        .i_rd_en(fifo_rd_en),      // Controlled by encryption engine
        .o_rd_data(fifo_data_out), // Data output for encryption
        .o_empty(fifo_empty),
        .o_full(fifo_full),
        .o_count(fifo_count)
    );

    // TODO: FSM for Encryption Engine usage <IDLE / ENCRYPT / DONE>

    // Encryption Engine Instance
    EncryptionEngine #(
        .WIDTH(DATA_WIDTH),
        .KEY_SIZE(KEY_SIZE)
    ) enc_engine (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_key(i_key),                // Encryption key
        .i_data_in(fifo_data_out),    // Data from FIFO
        .i_start(!fifo_empty),        // Start encryption when data is available
        .o_data_out(encrypted_data_out),
        .o_done(encryption_done)
    );

    // Assign encrypted data and done signal
    assign o_encrypted_data = encrypted_data_out;
    assign o_done = encryption_done;

    // FIFO read enable
    assign fifo_rd_en = (!fifo_empty && encryption_done);  // Ensure FIFO is not empty

    // Future W5500 integration placeholder
    assign o_w5500_rst = i_rst;  // Adjust as per the W5500 reset requirements



endmodule

