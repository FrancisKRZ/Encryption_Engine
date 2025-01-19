`timescale 1ns/1ps

module W5500Driver_TB;

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter IP_ADDR = 32'hC0A80001;
    parameter GATEWAY_ADDR = 32'hC0A80001;
    parameter SUBNET_MASK = 32'hFFFFFF00;
    parameter PORT = 16'h1337;

    // Testbench Signals
    reg i_clk;
    reg i_rst;
    reg i_spi_miso;
    wire o_spi_mosi;
    wire o_spi_clk;
    wire o_spi_cs;
    wire o_w5500_rst;
    reg i_w5500_int;
    wire o_busy;
    wire [DATA_WIDTH-1:0] o_data_out;
    wire o_data_ready;

    // Clock generation
    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk; // 100 MHz clock
    end

    // Reset and stimulus
    initial begin
        // Initialize inputs
        i_rst = 1;
        i_spi_miso = 0;
        i_w5500_int = 0;

        // Release reset
        #20 i_rst = 0;

        // Simulate SPI input
        #100 i_spi_miso = 1;  // Set SPI MISO signal high
        #50  i_spi_miso = 0;  // Set SPI MISO signal low

        // Simulate W5500 interrupt
        #200 i_w5500_int = 1;
        #50  i_w5500_int = 0;

        // Wait for the driver to process data
        #500 $finish;
    end

    // DUT Instance
    W5500Driver #(
        .DATA_WIDTH(DATA_WIDTH),
        .IP_ADDR(IP_ADDR),
        .GATEWAY_ADDR(GATEWAY_ADDR),
        .SUBNET_MASK(SUBNET_MASK),
        .PORT(PORT)
    ) UUT (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_spi_miso(i_spi_miso),
        .o_spi_mosi(o_spi_mosi),
        .o_spi_clk(o_spi_clk),
        .o_spi_cs(o_spi_cs),
        .o_w5500_rst(o_w5500_rst),
        .i_w5500_int(i_w5500_int),
        .o_busy(o_busy),
        .o_data_ready(o_data_ready),
        .o_data_out(o_data_out)
    );

    // Dump waveforms
    initial begin
        $dumpfile("W5500Driver_TB.vcd");
        $dumpvars(0, W5500Driver_TB);
    end

endmodule
