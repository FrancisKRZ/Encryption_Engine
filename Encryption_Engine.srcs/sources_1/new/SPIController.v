`timescale 1ns / 1ps

// Working SPI -- No need to update future me!

/*
    clk         System Clock
    rst         Reset Signal
    
    data_in     Data In
    start       Start Signal
    miso        Master In-Slave Out
    
    data_out    Data Received via MISO
    done        SPI Transaction Done
    mosi        Master Out-Slave In
    spi_clk     SPI Clock Signal for Sync
    cs          SPI Chip Select


    Finite State Machine Design:
        IDLE:       Waiting for i_start signal
        SEND:       Shifts outs bits from o_spi_mosi whilst toggling o_spi_clk
        RECEIVE:    Capture data on i_spi_miso during correct clock phase <perhaps use Hamming codes(?)>
        DONE:       Assert done status and wait for reset or next transaction signal


    Since the SPI runs slower than the system clock, we've a Fast Domain to Slow Domain situation,
    as we've seen in the book -- we can remediate by making the source domain's signal longer to synchronize
    with the slower domain's <we'll achieve it by dividing our i_clk by a counter to generate o_spi_clk>


    In order to parallelize our data from serial, we'll utilize a shift register as seen in the book.
        8-bit shift register for transmitting i_data_in on o_spi_mosi
        8-bit shift register for collecting data from i_spi_miso for o_data_out


    Control Signals will be managed by o_spi_cs to assert a low signal at the start of a transaction
    then deassert a high signal after o_done

*/

module SPIController #(
    parameter DATA_WIDTH = 8,
    parameter CPOL      = 0,    // Clock polarity
    parameter CPHA      = 0     // Clock phase
)(
    input  wire                    i_clk,    
    input  wire                    i_rst,
    input  wire [DATA_WIDTH-1:0]   i_data_in,
    input  wire                    i_start,
    output reg  [DATA_WIDTH-1:0]   o_data_out,
    output reg                     o_done,
    output reg                     o_spi_mosi,
    input  wire                    i_spi_miso,
    output wire                    o_spi_clk,
    output reg                     o_spi_cs,
    input  wire [7:0]             i_clk_div,
    output reg                     o_busy
);

    // State encoding
    localparam [2:0] 
        IDLE    = 3'b000,
        SETUP   = 3'b001,
        SHIFT   = 3'b010,
        DONE    = 3'b011;

    // Registers
    reg [2:0]  state;
    reg [7:0]  clk_counter;
    reg [3:0]  bit_counter;  // Changed to 4 bits for better counting
    reg [DATA_WIDTH-1:0] tx_shift_reg;
    reg [DATA_WIDTH-1:0] rx_shift_reg;
    reg        spi_clk_internal;
    reg        spi_clk_prev;  // For edge detection

    // Clock generation
    always @(posedge i_clk or posedge i_rst) begin

        if (i_rst) begin
            clk_counter <= 0;
            spi_clk_internal <= CPOL;
            spi_clk_prev <= CPOL;

        end else if (state != IDLE) begin

            // Clock cycle generation for delays in Cross Clock Domain
            if (clk_counter >= i_clk_div - 1) begin
                clk_counter <= 0;
                spi_clk_internal <= ~spi_clk_internal;
            end else begin
                clk_counter <= clk_counter + 1'b1;
            end
            spi_clk_prev <= spi_clk_internal;

        end else begin

            spi_clk_internal <= CPOL;
            spi_clk_prev <= CPOL;

        end
    end

    // SPI clock output
    assign o_spi_clk = spi_clk_internal;

    // Edge detection
    wire spi_clk_posedge = spi_clk_internal && !spi_clk_prev;
    wire spi_clk_negedge = !spi_clk_internal && spi_clk_prev;

    // Main state machine
    always @(posedge i_clk or posedge i_rst) begin

        if (i_rst) begin

            state <= IDLE;
            o_spi_cs <= 1'b1;
            o_done <= 1'b0;
            o_busy <= 1'b0;
            bit_counter <= 0;
            tx_shift_reg <= 0;
            rx_shift_reg <= 0;
            o_spi_mosi <= 1'b0;
            o_data_out <= 0;

        end else begin

            case (state)
                IDLE: begin
                    o_done <= 1'b0;
                    o_spi_cs <= 1'b1;
                    bit_counter <= 0;
                    
                    if (i_start) begin
                        state <= SETUP;
                        tx_shift_reg <= i_data_in;
                        o_busy <= 1'b1;
                        o_spi_cs <= 1'b0;
                    end
                end

                SETUP: begin
                    o_spi_mosi <= tx_shift_reg[DATA_WIDTH-1];
                    state <= SHIFT;
                end

                SHIFT: begin
                    if (spi_clk_posedge) begin

                        if (CPHA == 0) begin
                            // Sample MISO on rising edge for CPHA=0
                            rx_shift_reg <= {rx_shift_reg[DATA_WIDTH-2:0], i_spi_miso};
                            bit_counter <= bit_counter + 1;
                            
                        end else begin
                            // Change MOSI on rising edge for CPHA=1
                            tx_shift_reg <= {tx_shift_reg[DATA_WIDTH-2:0], 1'b0};
                            o_spi_mosi <= tx_shift_reg[DATA_WIDTH-2];
                        end

                    end else if (spi_clk_negedge) begin

                        if (CPHA == 0) begin
                            // Change MOSI on falling edge for CPHA=0
                            tx_shift_reg <= {tx_shift_reg[DATA_WIDTH-2:0], 1'b0};
                            o_spi_mosi <= tx_shift_reg[DATA_WIDTH-2];

                        end else begin
                            // Sample MISO on falling edge for CPHA=1
                            rx_shift_reg <= {rx_shift_reg[DATA_WIDTH-2:0], i_spi_miso};
                            bit_counter <= bit_counter + 1;
                        end

                    end

                    // Check for completion
                    if (bit_counter >= DATA_WIDTH) begin
                        state <= DONE;
                    end

                end

                DONE: begin
                    o_data_out <= rx_shift_reg;
                    o_done <= 1'b1;
                    o_busy <= 1'b0;
                    o_spi_cs <= 1'b1;
                    state <= IDLE;
                end

                default: state <= IDLE;

            endcase
            
        end // eof else (not reset)
    end // eof always block

endmodule
