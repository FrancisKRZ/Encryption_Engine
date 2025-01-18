`timescale 1ns / 1ps

// A First-In First-Out RAM implementation, based on Getting Started with FPGAs provided examples
// Infers a Dual Port RAM (DPRAM) Based FIFO using a single clock
// Uses a Dual Port RAM but automatically handles read/write addresses.
// Parameters: 
// WIDTH     - Width of the FIFO
// DEPTH     - Max number of items able to be stored in the FIFO
//
// This FIFO cannot be used to cross clock domains, because in order to keep count
// correctly it would need to handle all metastability issues. 
// If crossing clock domains is required, use FIFO primitives directly from the vendor.


module FIFO_RAM #(
    parameter WIDTH = 8, 
    parameter DEPTH = 256
    )(
    input i_clk,
    input i_rst,
    input  [WIDTH-1:0] i_wr_data,
    input i_wr_en,
    input i_rd_en,
    output reg [WIDTH-1:0] o_rd_data,  // o_rd_data is now a reg
    output o_empty,
    output o_full
    );

    // The internal memory for the FIFO dual-port RAM
    reg [WIDTH-1:0] ram [DEPTH-1:0];

    // Read / Write pointers
    reg [$clog2(DEPTH)-1:0] r_wr_ptr;
    reg [$clog2(DEPTH)-1:0] r_rd_ptr;

    // Counter to track the number of elements in the FIFO
    reg [$clog2(DEPTH):0] r_count;

    // Write logic
    always @(posedge i_clk or negedge i_rst) begin

        if (!i_rst) begin
            r_wr_ptr <= 0;
        
        end else if (i_wr_en && !o_full) begin

            ram[r_wr_ptr] <= i_wr_data;
            r_wr_ptr <= r_wr_ptr + 1;
        
        end
    end

    // Read logic
    always @(posedge i_clk or negedge i_rst) begin

        if (!i_rst) begin
        
            r_rd_ptr <= 0;
            o_rd_data <= 0;  // Directly update o_rd_data here

        end else if (i_rd_en && !o_empty) begin
        
            o_rd_data <= ram[r_rd_ptr];  // Read from RAM and assign to o_rd_data
            r_rd_ptr <= r_rd_ptr + 1;
        
        end
    end

    // Counter logic
    always @(posedge i_clk or negedge i_rst) begin

        if (!i_rst) begin
        
            r_count <= 0;
        
        end else begin
            // If Writing and not Full
            if (i_wr_en && !o_full) begin
                r_count <= r_count + 1;
            end
            // If Reading and not Empty
            if (i_rd_en && !o_empty) begin
                r_count <= r_count - 1;
            end
        
        end
    end

    // Full and empty flags
    assign o_full  = r_count == DEPTH;
    assign o_empty = r_count == 0;

endmodule


 