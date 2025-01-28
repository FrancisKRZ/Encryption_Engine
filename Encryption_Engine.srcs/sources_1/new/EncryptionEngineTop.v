`timescale 1ns / 100ps


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
//	W5500 Parameters File
//	FIFO-RAM Module
//	
// 
// Dependencies: N/A
// 
// Revision 2.01 -  Implementation Order: W5500 INPUT -> RAW FIFO -> ENC ENGINE -> ENC FIFO -> W5500 OUTPUT
//
//                  The second revision merges SPI and W5500 Drivers into a W5500 Driver based on Harouts' work
//                  It has a more rigid and smaller structure and flow            
// 
// 
// 
//////////////////////////////////////////////////////////////////////////////////



/*
________________________________________________________________________________________
W5500 Port Connections on Basys 3:

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
    parameter KEY_SIZE = 32,  // 32-bit key for encryption
    parameter DATA_WIDTH = 8, // Same size as W5500's data_read
    parameter DEPTH = 1024    // Used for FIFOs
)(
    input i_clk,                                // System clock
    input i_rst,                                // Reset signal
    // SPI Signals
    input i_spi_miso,                           // ETH MISO (input from W5500)
    output o_spi_mosi,                          // ETH MOSI (output to W5500)
    output o_spi_clk,                           // ETH CLK (output to W5500)
    output o_spi_cs,                            // ETH CS (output to W5500)

    input i_w5500_int,                          // Interrupt signal from W5500
    output o_w5500_rst                          // Reset signal for W5500
);


    /*        ETHERNET MODULE SECTION              */

    // Instiate W5500Driver Module and Parameters
    `include "w5500_parameters.v"

    wire ethernet_available;
    reg [47:0] data_to_ethernet = 48'b111111000000_111111000000_111111000000_111111000000;
    reg data_out_valid = 1'b0;
    reg flush_requested = 1'b0;
    // Self used to wire data MISO to FIFO
    wire [7:0] w_data_read;

    `ifdef WIZNET5500_ACCEPT_INSTRUCTIONS
        reg [31:0] instruction_input = 32'd0;
        reg instruction_input_valid = 1'b0;
    `endif


    W5500Driver eth_iface (
        // System Clock
        .clk(i_clk),
        // Physical Connections
        .miso(i_spi_miso),
        .mosi(o_spi_mosi),
        .spi_clk(o_spi_clk),
        .spi_chip_select_n(o_spi_cs),
        // Internal status signals
        .is_available(ethernet_available),
        .data_input(data_to_ethernet),                      // Input signal, writes to MOSI
        .data_input_valid(data_out_valid),                  // Input signal validation
        .flush_requested(flush_requested)
        // Read from MISO < >
        `ifdef WIZNET5500_READ_DATA
        .data_read(data_read),                              // Output signal, reads from MISO
        .data_read_valid(data_read_valid),                  // Output signal validation
        `endif

        `ifdef WIZNET5500_ACCEPT_INSTRUCTIONS
        .instruction_input_valid(instruction_input_valid),
        .instruction_input(instruction_input),              
        `endif

    ); // Ethernet Module


    // Output from W5500's MISO
    // assign w_data_read = data_read_valid ? data_read : 0'b0;

    /*        FIFO SECTION              */

    localparam ADDR_WIDTH = $clog2(DATA_WIDTH);

    // FIFO <Raw Frames> Instantiation and Parameters
    reg [DATA_WIDTH-1:0] raw_w_fifo_data_out;        // Data output from FIFO
    reg raw_r_fifo_wr_en;                            // FIFO write enable
    reg  raw_r_fifo_rd_en;                            // FIFO read enable
    wire raw_w_fifo_empty, raw_w_fifo_full;           // FIFO status flags
    wire [ADDR_WIDTH:0] raw_w_fifo_count;

    FIFO_RAM #(
        .WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) raw_frames_fifo (
        // System clock and reset
        .i_clk(i_clk),
        .i_rst(i_rst),

        // Inputs, raw data frames from eth_iface's MISO
        .i_wr_data(w_data_read),                    // Reading raw ethernet frames
        .i_wr_en(raw_r_fifo_wr_en),
        .i_rd_en(raw_r_fifo_rd_en),

        // Outputs
        .o_rd_data(raw_w_fifo_data_out),
        .o_empty(raw_w_fifo_empty),
        .o_full(raw_w_fifo_full),
        .o_count(raw_w_fifo_count)
        
    ); // FIFO Raw Frames Module


    // FIFO <Encrypted Frames> Instantiation and Parameters

    reg [DATA_WIDTH-1:0] enc_w_fifo_data_out;        // Data output from FIFO
    wire enc_w_fifo_wr_en;                            // FIFO write enable
    reg  enc_r_fifo_rd_en;                            // FIFO read enable
    wire enc_w_fifo_empty, enc_w_fifo_full;           // FIFO status flags
    wire [ADDR_WIDTH:0] enc_w_fifo_count;


    FIFO_RAM #(
        .WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) enc_frames_fifo (

         // System clock and reset
        .i_clk(i_clk),
        .i_rst(i_rst),

        // Inputs, raw data frames from eth_iface's MISO
        .i_wr_data(w_encrypted_data),                    // Reading raw ethernet frames from enc_engine
        .i_wr_en(enc_w_fifo_wr_en),
        .i_rd_en(enc_r_fifo_rd_en),

        // Outputs
        .o_rd_data(enc_w_fifo_data_out),
        .o_empty(enc_w_fifo_empty),
        .o_full(enc_w_fifo_full),
        .o_count(enc_w_fifo_count)       
        
    ); // FIFO Encrypted Frames Module


    /*     ENCRYPTION ENGINE        */

    localparam ENCRYPTION_KEY = 32'h539;        // Internal Key <Until I figure out ethernet frames and use that instead>
    wire [DATA_WIDTH-1:0] w_read_raw_fifo;
    wire w_read_raw_fifo_enable;
    wire [DATA_WIDTH-1:0] w_encrypted_data;

    // Input comes from RAW FIFO output goes to ENC FIFO
    EncryptionEngine #(
        .WIDTH(WIDTH),
        .KEY_SIZE(KEY_SIZE)
    ) enc_engine (
        // System Clock and Reset
        .i_clk(i_clk),
        .i_rst(i_rst),
        // Engine signals
        .i_key(ENCRYPTION_KEY),                 // Encryption Key
        .i_data_in(w_read_raw_fifo),            // Reads from the Raw FIFO, Controlled by FSM
        .i_start(w_read_raw_fifo_enable),       // In FSM when true; read
        .o_data_out(w_encrypted_data)

    ); // Encryption Engine Module


    /*    Finite State Machine      */
    // Controlling when to write into raw_fifo from eth_iface
    // when to read from raw_fifo into enc_engine
    // when to write to enc_fifo 
    // when to read to eth_iface from enc_fifo

    // Machine Idle , Reset or Done
    localparam IDLE         = 4'b0000;
    localparam RESET        = 4'b0111;
    localparam DONE         = 4'b1000;

    // Read/Write into Raw FIFO
    localparam READ_RAW     = 4'b0001;
    localparam WRITE_RAW    = 4'b0010;

    // Encryption Engine Controls
    localparam ENC_START    = 4'b0011;
    localparam ENC_READ     = 4'b0100;

    // Read/Write into Enc FIFO
    localparam READ_ENC     = 4'b0101;
    localparam WRITE_ENC    = 4'b0110;

    // Control current and next state
    reg [3:0] r_current_state, r_next_state;

    // We will need to append encrypted data's 8-bit to 48-bit
    // in order to have a working flush control


    // Sequential Finite State Machine
    always @(posedge i_clk or posedge i_rst) begin

        // All FIFO's rd/wr enable signals are off
        // ethernet flush is requested
        if (i_rst) begin
            // Set Machine IDLE
            r_current_state <= IDLE;
            
            // Raw FIFO
            raw_r_fifo_rd_en <= 0'b0;
            raw_r_fifo_wr_en = 0'b0;
            // Enc FIFO
            enc_r_fifo_rd_en <= 0'b0;
            enc_w_fifo_wr_en = 0'b0;
            
        end // end of reset

        // Initialize Machine next state
        else begin
            r_current_state <= r_next_state;
        end

    end // end Sequential FSM


    // Combinational Finite State Machine
    always (*) begin

        r_next_state <= r_current_state;

        case (r_current_state)

            // IDLE: Determine next state
            IDLE: begin
                // If RAW FIFO is not full and the eth data is valid
                if (!raw_w_fifo_full && data_read_valid) begin
                    r_next_state <= WRITE_RAW;
                end

                // If RAW FIFO is not empty and the ENC FIFO is not full
                else if (!raw_w_fifo_empty && !enc_w_fifo_full) begin
                    r_next_state <= READ_RAW;
                end 
            
            end // end IDLE

            // WRITE: Write raw data to RAW FIFO
            WRITE_RAW: begin

                raw_r_fifo_wr_en <= 1'b1;

                // Have to confirm this conditional
                if (ethernet_available) begin
                    assign w_data_read = data_read;
                end else begin
                    r_next_state <= IDLE;
                end

                r_next_state <= READ_RAW;

            end // end WRITE_RAW

            // READ: Reads from raw fifo to encryption engine
            READ_RAW: begin

                raw_r_fifo_rd_en <= 1'b1;
                r_next_state <= ENC_START;

            end // end READ_RAW

            // START: Enables the read operation from RAW and writes enc engine
            ENC_START: begin

                w_read_raw_fifo_enable <= 1'b1;
                assign w_read_raw_fifo = raw_w_fifo_data_out;

                // Takes data from raw FIFO into the encryption engine

                r_next_state <= ENC_READ;

            end // end ENC_START

            // READ: Reads the output from the enc engine into the ENC FIFO
            ENC_READ: begin

                r_next_state <= WRITE_ENC;

            end


            // WRITE: Writes the enc data into the ENC FIFO
            WRITE_ENC: begin

                enc_w_fifo_wr_en <= 1'b1;
                r_next_state <= READ_ENC;

            end // end WRITE_ENC


            // READ: Reads from enc FIFO out to the eth iface's output data_to_ethernet and data_out_valid enable
            READ_ENC: begin
                
                enc_r_fifo_rd_en <= 1'b1;
                data_to_ethernet <= enc_w_fifo_data_out;

                r_next_state <= IDLE;

            end

            // Default State
            default: begin
                r_next_state <= IDLE;
            end


        endcase

    end // end combinational always
    


endmodule





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
