`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/18/2025 10:52:34 AM
// Design Name: 
// Module Name: EncryptionEngine
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


module EncryptionEngine(
    input i_clk,
    input i_rst,
    input  [127:0] i_key,
    input  [7:0] i_data_in,
    input i_start,
    output [7:0] o_data_out,
    output o_done
    );
    

    /*  
        Encryption Engine Finite State Machine

        It will have three states: 
            Idle: Waiting for Start Signal (i_start)
            Encrypt: Encryption in Process, equivalent of Rd_En = 0 of a FIFO 
            Done: Encryption Complete, equivalent of Rd_En = 1 of a FIFO
    */

    typedef enum logic [1:0] {
        IDLE = 2'b00,
        ENCRYPT = 2'b01,
        DONE = 2'b10
    } state_t;

    // FSM state
    state_t current_state, next_state;

    // Registers for holding the 128-bit key and temporary data holding register
    reg [127:0] key_register;
    reg [7:0] data_register;
    
    
    // State Machine Logic, using 1 always block (as seen in R8's 'The State Machine')
    // with Sequential Logic instead of Combinatorial to avoid latches :)
    always @(posedge i_clk or negedge i_rst) begin

        if (!i_rst) begin

            current_state   <= IDLE;
            key_register    <= 128'b0;
            data_register   <= 8'b0;
            o_data_out      <= 8'b0;
            o_done          <= 1'b0;

        end else begin

            current_state <= next_state;

            // Now we'll load input data and key for when the encryption process starts
            if (current_state == IDLE && i_start) begin

                key_register    <= i_key;
                data_register   <= i_data_in;

            end

            // We'll now output the encrypted data into the DONE state
            if (current_state == DONE) begin

                // Using a XOR cypher, can be changed to our needs!
                o_data_out <= data_register ^ key_register[7:0];
                o_done <= 1'b0;

            end else begin

                // Now we may clear the done signal
                o_done <= 1'b0;
            
            end 
        

        end // end of State Machine body


    end // end of always block


    
endmodule
