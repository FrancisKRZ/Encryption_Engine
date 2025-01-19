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
    output reg o_spi_mosi,             // SPI MOSI (to W5500)
    output reg o_spi_clk,              // SPI Clock (SCLK)
    output reg o_spi_cs,               // SPI Chip Select (CS)
    output wire o_w5500_rst,           // W5500 Reset
    input wire i_w5500_int,            // W5500 Interrupt
    output wire o_busy,                // Indicate if W5500 is busy
    output reg o_data_ready,           // Data ready flag (indicates received data)
    output reg [DATA_WIDTH-1:0] o_data_out // Data output (received data)
);

    // Internal registers for SPI communication
    reg [7:0] tx_buffer;               // Transmission buffer for SPI
    reg [7:0] rx_buffer;               // Receiver buffer for SPI
    reg spi_start, spi_done;           // SPI control signals

    // FSM states
    localparam IDLE         = 4'b0000;
    localparam INIT         = 4'b0001;
    localparam SEND_DATA    = 4'b0010;
    localparam RECEIVE_DATA = 4'b0100;
    localparam WAIT_INT     = 4'b1000;

    reg [3:0] r_current_state, r_next_state;

    // SPI register addresses for W5500 configuration
    localparam W5500_GAR = 16'h0001;   // Gateway address register
    localparam W5500_SUBR = 16'h0005;  // Subnet mask register
    localparam W5500_SHAR = 16'h0009;  // Source hardware address register
    localparam W5500_SIPR = 16'h000F;  // Source IP address register
    localparam W5500_PORT = 16'h0014;  // Source port register

    // Initialize W5500 configuration (IP, subnet, gateway, and port)
    task initialize_w5500;
        begin
            // Write Gateway Address
            spi_write(W5500_GAR, GATEWAY_ADDR[31:24]);
            spi_write(W5500_GAR + 1, GATEWAY_ADDR[23:16]);
            spi_write(W5500_GAR + 2, GATEWAY_ADDR[15:8]);
            spi_write(W5500_GAR + 3, GATEWAY_ADDR[7:0]);

            // Write Subnet Mask
            spi_write(W5500_SUBR, SUBNET_MASK[31:24]);
            spi_write(W5500_SUBR + 1, SUBNET_MASK[23:16]);
            spi_write(W5500_SUBR + 2, SUBNET_MASK[15:8]);
            spi_write(W5500_SUBR + 3, SUBNET_MASK[7:0]);

            // Write IP Address
            spi_write(W5500_SIPR, IP_ADDR[31:24]);
            spi_write(W5500_SIPR + 1, IP_ADDR[23:16]);
            spi_write(W5500_SIPR + 2, IP_ADDR[15:8]);
            spi_write(W5500_SIPR + 3, IP_ADDR[7:0]);

            // Write Port
            spi_write(W5500_PORT, PORT[15:8]);
            spi_write(W5500_PORT + 1, PORT[7:0]);
        end
    endtask

    // SPI Write Operation
    task spi_write(input [15:0] address, input [7:0] data);
        begin
            // Assert chip select
            o_spi_cs <= 1'b0;

            // Send address high byte
            tx_buffer <= address[15:8];
            spi_start <= 1'b1;
            @(posedge spi_done);

            // Send address low byte
            tx_buffer <= address[7:0];
            spi_start <= 1'b1;
            @(posedge spi_done);

            // Send data
            tx_buffer <= data;
            spi_start <= 1'b1;
            @(posedge spi_done);

            // Deassert chip select
            o_spi_cs <= 1'b1;
        end
    endtask

    // FSM Logic
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst)
            r_current_state <= IDLE;
        else
            r_current_state <= r_next_state;
    end

    always @(*) begin
        r_next_state = r_current_state;
        case (r_current_state)
            IDLE: begin
                if (i_rst)
                    r_next_state = INIT;
            end
            INIT: begin
                initialize_w5500();
                r_next_state = WAIT_INT;
            end
            WAIT_INT: begin
                if (i_w5500_int)
                    r_next_state = RECEIVE_DATA;
            end
            RECEIVE_DATA: begin
                o_data_ready = 1'b1;
                r_next_state = WAIT_INT;
            end
        endcase
    end

    // Assignments
    assign o_busy = (r_current_state != IDLE);
    assign o_w5500_rst = i_rst;

endmodule
