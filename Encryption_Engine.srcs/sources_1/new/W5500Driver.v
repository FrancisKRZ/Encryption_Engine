`timescale 1ns / 1ps

/*
    This module may be a behemoth...

    Firstly, we shall initialize the module itself as a subroutine,
    its IP addresses, subnet, gateway and ports will be abstracted and/or simplified.
    (I've yet to take the formal Computer Networks course (which I will this semester))

    Then assert proper SPI communication, the SPI will send data to the W5500 as a FSM
    {SEND_DATA, RECEIVE_DATA}, for which data is transmitted via the SPI MOSI and received
    via the SPI MISO Pmod ports respectively.

    The interrupt handle signal will be implemented as well for the i_w5500_int which will
    have a connection with the SPI itself. This way it'll know when to read incoming
    data from the W5500.
    Once the interrupt is signaled in, the FSM will enter RECEIVE_DATA state in order
    to fetch data from the W5500 module's Pmod pins.

    It will then output data into our FIFO as indicated by o_data_ready and o_busy
    will show when the driver is active involved in communication.

    NOTE: The following implementation has basis from: https://github.com/harout/concurrent-data-capture/tree/master

*/

module W5500Driver #(
    parameter DATA_WIDTH = 8,          // Data width (in bits)
    parameter IP_ADDR = 32'hC0A80001,  // Default IP address (192.168.0.1)
    parameter GATEWAY_ADDR = 32'hC0A80001, // Gateway IP address
    parameter SUBNET_MASK = 32'hFFFFFF00, // Subnet mask (255.255.255.0)
    parameter PORT = 16'h1337          // Default port
)(
    input wire i_clk,                  // System clock
    input wire i_rst,                  // Reset signal
    input wire i_spi_miso,             // SPI MISO (from W5500)
    output wire o_spi_mosi,            // SPI MOSI (to W5500)
    output wire o_spi_clk,             // SPI Clock (SCLK)
    output wire o_spi_cs,              // SPI Chip Select (CS)
    output wire o_w5500_rst,           // W5500 Reset
    input wire i_w5500_int,            // W5500 Interrupt
    output wire o_busy,                // Indicate if W5500 is busy
    output reg o_data_ready,          // Data ready flag (indicates received data)
    output reg [DATA_WIDTH-1:0] o_data_out // Data output (received data)
);

    // Internal registers for communication
    reg [7:0] tx_buffer;            // Transmission buffer for SPI
    reg [7:0] rx_buffer;            // Reception buffer for SPI
    reg [15:0] socket_buffer;       // Buffer to handle data between W5500 and FIFO
    reg [31:0] ip_addr;             // IP Address (set to default)
    reg [31:0] gateway_addr;        // Gateway IP Address
    reg [31:0] subnet_mask;         // Subnet mask

    // State machines state for initialization and data transfer
    localparam IDLE         = 4'b0000;
    localparam INIT         = 4'b0001;
    localparam SEND_DATA    = 4'b0010;
    localparam RECEIVE_DATA = 4'b0100;
    localparam WAIT_INT     = 4'b1000;

    reg [1:0] r_current_state, r_next_state;


    // SPI control signals
    reg [7:0] spi_data_in;
    reg spi_start, spi_done;
    
    // Initialize W5500 configuration (IP, subnet, gateway)
    task initialize_w5500;
        // Write default IP, gateway, subnet, and port to W5500 registers using SPI
        // These should map to specific registers in the W5500, e.g., W5500_Sn_CR, W5500_Sn_IR
        // You need to use SPI to send data to the W5500 to configure it.
    endtask

    // SPI Communication logic
    always @(posedge i_clk) begin
        if (i_rst) begin
            r_current_state <= IDLE;
        end else begin
            r_current_state <= r_next_state;
        end
    end

    always @(*) begin
        case (r_current_state)
            IDLE: begin
                // Reset the system or wait for initialization
                r_next_state = INIT;
            end
            INIT: begin
                // Initialize W5500
                r_next_state = SEND_DATA;
            end
            SEND_DATA: begin
                // Send data to W5500 for transmission over Ethernet
                r_next_state = WAIT_INT;
            end
            RECEIVE_DATA: begin
                // Retrieve data from W5500 into the FIFO
                r_next_state = WAIT_INT;
            end
            WAIT_INT: begin
                // Wait for an interrupt to signal incoming data or other events
                if (i_w5500_int) begin
                    r_next_state = RECEIVE_DATA;
                end else begin
                    r_next_state = SEND_DATA;
                end
            end
            default: begin
                r_next_state = IDLE;
            end
        endcase
    end

    // SPI data transfer logic (send/receive)
    always @(posedge i_clk) begin
        if (spi_done) begin
            // Handle SPI transmission completion and data receipt
            if (r_current_state == RECEIVE_DATA) begin
                o_data_out <= rx_buffer;  // Send received data to FIFO
                o_data_ready <= 1;        // Data is ready to be processed
            end
        end
    end

    // Reset the W5500
    assign o_w5500_rst = (r_current_state == INIT);

    // SPI Control Signals
    assign o_spi_mosi = spi_data_in;   // Output to MOSI
    assign o_spi_clk = i_clk;          // Clock signal for SPI
    assign o_spi_cs = (r_current_state != IDLE);  // Chip select (active when not in idle state)

    // Output busy signal when communication is ongoing
    assign o_busy = (r_current_state != IDLE);

endmodule
