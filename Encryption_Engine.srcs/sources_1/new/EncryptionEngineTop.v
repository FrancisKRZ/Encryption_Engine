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
    input i_clk,
    input i_rst,
    input i_spi_miso,
    output o_spi_mosi,
    output o_spi_clk,
    output o_spi_cs,
    output o_w5500_rst,
    input i_w5500_int,
    input  [127:0] i_key,
    output [7:0] o_encrypted_data,
    input i_start,
    output o_done
    );
endmodule
