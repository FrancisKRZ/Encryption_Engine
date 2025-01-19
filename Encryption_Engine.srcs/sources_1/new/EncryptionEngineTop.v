`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: 🐧
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
// Revision 1.01 - Implementation Order: ENCRYPTION ENGINE > FIFO_RAM > FIFO IP > SPI CONTROLLER > W5500 DRIVER
// Additional Comments:
// 
// How it works: FIFO is instantiated. 
// SPI is instantiated which instantiates W5500 when required TX/RX
// SPI tx into FIFO -> FIFO wr into EncryptionEngine
// Encryption Engine rd into SPI -> SPI into W5500
// W5500 handles lowest level ethernet frame packets whilst TX/RX
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

	MOSI -> JA1	    JA[0]
 	MISO -> JA2	    JA[1]
	SCLK -> JA3	    JA[2]
	CS   -> JA4     JA[3]
		
    VCC  -> JA5
    GND  -> JA6
	
	RST  -> JA7	    JA[4]
	INT  -> JA8	    JA[5]
	
________________________________________________________________________________________
*/


module EncryptionEngineTop #(
    parameter KEY_SIZE = 32,  // Originally had 128-bit size, however Basys 3 has 16 switches, we'll use 32 bit-key (2^4) 4 switches
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 256
)(
    input i_clk,                                // System clock
    input i_rst,                                // Reset signal
    input i_spi_miso,                           // SPI MISO (Master In Slave Out)
    output o_spi_mosi,                          // SPI MOSI (Master Out Slave In)
    output o_spi_clk,                           // SPI Clock
    output o_spi_cs,                            // SPI Chip Select
    output o_w5500_rst,                         // Reset for W5500
    input i_w5500_int,                          // Interrupt from W5500
    input [KEY_SIZE-1:0] i_key,                 // encryption key
    output [DATA_WIDTH-1:0] o_encrypted_data,   // Output encrypted data
    input i_start,                              // Start signal for encryption
    output reg o_done                           // Done signal indicating encryption completion
);

    // Internal signals for SPI, FIFO, Encryption
    wire [DATA_WIDTH-1:0] spi_data_out;        // Data received from SPI
    wire spi_done;                             // SPI transfer complete signal
    reg fifo_wr_en;                            // FIFO write enable
    reg fifo_rd_en;                            // FIFO read enable
    wire fifo_empty;                           // FIFO empty flag
    wire fifo_full;                            // FIFO full flag
    wire [DATA_WIDTH-1:0] fifo_data_out;       // Data read from FIFO
    wire [DATA_WIDTH-1:0] encrypted_data_out;  // Data from the encryption engine
    wire encryption_done;                      // Encryption completion signal
    wire [$clog2(DEPTH)-1:0] fifo_count;       // FIFO count


    // Finite State Machines
    localparam IDLE       = 3'b000;
    localparam READ_SPI   = 3'b001;
    localparam ENCRYPT    = 3'b010;
    localparam WRITE_BACK = 3'b011;
    localparam DONE       = 3'b100;

    // States Alternations
    reg [2:0] current_state, next_state;

    // FSM Sequential Logic
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // FSM Combinational Logic
    always @(*) begin
        // Default assignments
        next_state = current_state;
        fifo_wr_en = 1'b0;
        fifo_rd_en = 1'b0;
        o_done = 1'b0;

        case (current_state)
            IDLE: begin
                if (i_start)
                    next_state = READ_SPI;
            end
            READ_SPI: begin
                fifo_wr_en = spi_done;
                // Write to FIFO when SPI transfer completes
                if (fifo_full || spi_done)
                    next_state = ENCRYPT;
            end
            ENCRYPT: begin
                // Read FIFO when not empty
                fifo_rd_en = !fifo_empty;
                if (encryption_done)
                    next_state = WRITE_BACK;
            end
            WRITE_BACK: begin
                // Placeholder, e.g., send encrypted data back via SPI
                next_state = DONE;
            end
            DONE: begin
                o_done = 1'b1;
                // Signal completion
                if (!i_start)
                    next_state = IDLE;
            end
        endcase
    end

    // SPI Controller Instance
    SPIController #(
        .DATA_WIDTH(DATA_WIDTH),
        .CPOL(0),   // Clock polarity
        .CPHA(0)    // Clock phase  <We may do Phaseshifts for our PLL as seen in R11>
    ) spi_ctrl (
        .i_clk(i_clk),
        .i_rst(i_rst),
        // A humble placeholder for outgoing data
        .i_data_in(8'h00),              
        .i_start(i_start),
        .o_data_out(spi_data_out),
        .o_done(spi_done),
        .o_spi_mosi(o_spi_mosi),
        .i_spi_miso(i_spi_miso),
        .o_spi_clk(o_spi_clk),
        .o_spi_cs(o_spi_cs),
        // SPI clock divider
        .i_clk_div(8'd4)    
    );

    // FIFO RAM Instance
    FIFO_RAM #(
        .WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) fifo_inst (
        .i_clk(i_clk),
        // Active-low reset
        .i_rst_n(!i_rst),
        // Data received from SPI          
        .i_wr_data(spi_data_out),  
        // Write enable controlled by FSM
        .i_wr_en(fifo_wr_en),  
        // Read enable controlled by FSM    
        .i_rd_en(fifo_rd_en),      
        // Data output for encryption
        .o_rd_data(fifo_data_out), 
        .o_empty(fifo_empty),
        .o_full(fifo_full),
        .o_count(fifo_count)
    );

    // Encryption Engine Instance
    EncryptionEngine #(
        .WIDTH(DATA_WIDTH),
        .KEY_SIZE(KEY_SIZE)
    ) enc_engine (
        .i_clk(i_clk),
        .i_rst(i_rst),
        // Encryption key
        .i_key(i_key),          
        // Data from FIFO      
        .i_data_in(fifo_data_out),  
        // Start encryption when data is available  
        .i_start(fifo_rd_en),         
        .o_data_out(encrypted_data_out),
        .o_done(encryption_done)
    );

    // Assign encrypted data and done signal
    assign o_encrypted_data = encrypted_data_out;
//    assign o_done = encryption_done;

    // FIFO read enable and ensures FIFO is not empty
//    assign fifo_rd_en = (!fifo_empty && encryption_done); 

    // Future W5500 integration placeholder
    assign o_w5500_rst = i_rst;  // Adjust as per the W5500 module reset requirements in specs


/*  If implemented FIFO RAM fails timing requirements, or aditional Error-Correction, ECC, encoding
    is required, we may instantiate IP Block generated FIFO
*/

    // FIFO IP instance
    // 8-bit width 256-bit depth 
    // FIFO_wrapper fifo_inst (
    //     .almost_empty_0(),      // Optional, may be used during Encryption Throttle
    //     .almost_full_0(),       // Optional, may be used during Encryption Throttle
    //     .din_0(din_0),          // Data input to FIFO
    //     .dout_0(dout_0),        // Data output from FIFO
    //     .empty_0(empty_0),      // FIFO empty flag
    //     .full_0(full_0),        // FIFO full flag
    //     .rd_en_0(rd_en_0),      // Read enable signal for FIFO
    //     .reset(i_rst),          // Reset signal for FIFO
    //     .sys_clock(i_clk),      // Clock signal for FIFO
    //     .wr_en_0(wr_en_0)       // Write enable signal for FIFO
    // );



endmodule

