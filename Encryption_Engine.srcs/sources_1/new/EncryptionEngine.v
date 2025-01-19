`timescale 1ns / 1ps

/*  
    Encryption Engine Finite State Machine

    It will have three states: 
        Idle: Waiting for Start Signal (i_start)
        Encrypt: Encryption in Process, equivalent of Rd_En = 0 of a FIFO 
        Done: Encryption Complete, equivalent of Rd_En = 1 of a FIFO
*/

module EncryptionEngine#(
    parameter WIDTH = 8, 
    parameter KEY_SIZE = 32 // changed from 128-bit
    )(
    input i_clk,
    input i_rst,
    input  [KEY_SIZE-1:0] i_key,
    input  [WIDTH-1:0] i_data_in,
    input i_start,
    output reg [WIDTH-1:0] o_data_out,
    output reg o_done
    );


    // Encryption Engine Finite State Machine
    localparam IDLE     = 2'b00;
    localparam ENCRYPT  = 2'b01;
    localparam DONE     = 2'b10;

    // FSM state
    reg [1:0] r_current_state, r_next_state;

    // Registers for holding the 128-bit key and temporary data holding register
    reg [127:0] key_register;
    reg [7:0] data_register;

    // State Machine Logic (Sequential Block)
    always @(posedge i_clk or negedge i_rst) begin
        
        if (!i_rst) begin
        
            r_current_state   <= IDLE;
            key_register      <= 128'b0;
            data_register     <= 8'b0;
            o_data_out        <= 8'b0;
            o_done            <= 1'b0;
        
        end else begin
            r_current_state <= r_next_state;

            // Loading input data and key for encryption when in IDLE and start signal is asserted
            if (r_current_state == IDLE && i_start) begin
                key_register    <= i_key;
                data_register   <= i_data_in;
            end

            // Performing encryption in DONE state
            if (r_current_state == DONE) begin
                // Applying XOR on the data
                o_data_out <= data_register ^ key_register[7:0];
                o_done <= 1'b1;  // Assert done signal when encryption is done

            end else begin
                o_done <= 1'b0;  // Clear done signal in other states
            end

        end

    end // end of State Machine body


    // Next State Logic (Combinational Block)
    always @(*) begin

        case (r_current_state)
        
            IDLE: begin
                if (i_start)
                    r_next_state = ENCRYPT;
                else
                    r_next_state = IDLE;
            end

            ENCRYPT: begin
                r_next_state = DONE;
            end

            DONE: begin
                // Stay in DONE state until i_start is deasserted
                if (!i_start)
                    r_next_state = IDLE;
                else
                    r_next_state = DONE;
            end

            default: r_next_state = IDLE;
        
        endcase
    
    end // end of Next State Logic

endmodule
