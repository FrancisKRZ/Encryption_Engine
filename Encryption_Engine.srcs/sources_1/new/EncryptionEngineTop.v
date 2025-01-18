`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/18/2025 10:52:34 AM
// Design Name: 
// Module Name: EncryptionEngineTop
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


/*
	MOSI -> JA1	Orange
 	MISO -> JA2	Brown
	SCLK -> JA3	Yellow
	CS   -> JA4	Grey

	RST  -> JA7	Green
	INT  -> JA8	Purple

________________________________________________________________________________________

W5500 Port Connections:

	MOSI -> JA1	
 	MISO -> JA2	
	SCLK -> JA3	
	CS   -> JA4	

	RST  -> JA7	
	INT  -> JA8	
	
Top Level Design:

	Encryption Engine: 
		(inouts <ethernet module pins>, 
		input clk, input reset)
	
		Instantiates:
			W5500 Ethernet Module Driver w/ Parameters
			
			FIFO-RAM Module
			
			Encryption Select (Inputs: Encryption Mode, Data):
				- Encrypt Function
				- Decrypt Function
				
				Outputs (Encrypted Data or Decrypted Data)
				

External Files:	
	W5500 Ethernet Module
	
	FIFO-RAM Module
	
	

________________________________________________________________________________________
*/


module EncryptionEngineTop(
    input i_clk,             // System clock
    input i_rst,             // Reset signal
    input i_spi_miso,        // SPI MISO (Master In Slave Out)
    output o_spi_mosi,       // SPI MOSI (Master Out Slave In)
    output o_spi_clk,        // SPI Clock
    output o_spi_cs,         // SPI Chip Select
    output o_w5500_rst,      // Reset for W5500
    input i_w5500_int,       // Interrupt from W5500
    input [127:0] i_key,     // 128-bit encryption key
    output [7:0] o_encrypted_data,  // Output encrypted data
    input i_start,           // Start signal for encryption
    output o_done            // Done signal indicating encryption completion
    );

    // FIFO IP instance
    FIFO_wrapper fifo_inst (
        .almost_empty_0(),      // Optional, may be used during Encryption Throttle
        .almost_full_0(),       // Optional, may be used during Encryption Throttle
        .din_0(din_0),          // Data input to FIFO
        .dout_0(dout_0),        // Data output from FIFO
        .empty_0(empty_0),      // FIFO empty flag
        .full_0(full_0),        // FIFO full flag
        .rd_en_0(rd_en_0),      // Read enable signal for FIFO
        .reset(i_rst),          // Reset signal for FIFO
        .sys_clock(i_clk),      // Clock signal for FIFO
        .wr_en_0(wr_en_0)       // Write enable signal for FIFO
    );

    // Additional encryption logic can be added here
    // Logic to interface with W5500, SPI, and encryption engine can be implemented

endmodule

