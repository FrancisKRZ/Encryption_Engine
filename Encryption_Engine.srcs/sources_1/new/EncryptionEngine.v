`timescale 1ns / 100ps

/*  
    Encryption Engine Finite State Machine

    It will have three states: 
        Idle: Waiting for Start Signal (i_start)
        Encrypt: Encryption in Process, equivalent of Rd_En = 0 of a FIFO 
        Done: Encryption Complete, equivalent of Rd_En = 1 of a FIFO
*/


module EncryptionEngine#(
    parameter WIDTH = 48, 
    parameter KEY_SIZE = 32
)(
    input i_clk,
    input i_rst,
    input  [KEY_SIZE-1:0] i_key,
    input  [WIDTH-1:0] i_data_in,
    input i_start,
    output reg [WIDTH-1:0] o_data_out
);

    // Encryption Engine Finite State Machine
    localparam IDLE     = 2'b00;
    localparam ENCRYPT  = 2'b01;
    localparam DONE     = 2'b10;

    // FSM state
    reg [1:0] r_current_state, r_next_state;

    // Registers for holding the 128-bit key and temporary data holding register
    reg [KEY_SIZE-1:0] key_register;
    reg [WIDTH-1:0] data_register;

    // State Machine Logic (Sequential Block)
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_current_state <= IDLE;
            key_register    <= {KEY_SIZE{1'b0}};
            data_register   <= {WIDTH{1'b0}};
            o_data_out      <= {WIDTH{1'b0}};
        end else begin
            r_current_state <= r_next_state;

            case (r_current_state)
                IDLE: begin
                    if (i_start) begin
                        key_register  <= i_key;
                        data_register <= i_data_in;
                    end
                end
                ENCRYPT: begin
                    // Perform encryption
                    o_data_out <= data_register ^ key_register;
                end
                DONE: begin
                    // No o_done signal is needed, so we'll just stay in this state until i_start is cleared
                end
            endcase
        end
    end

    // Next State Logic (Combinational Block)
    always @(*) begin
        case (r_current_state)
            IDLE:    r_next_state = i_start ? ENCRYPT : IDLE;
            ENCRYPT: r_next_state = DONE;
            DONE:    r_next_state = i_start ? DONE : IDLE;
            default: r_next_state = IDLE;
        endcase
    end

endmodule