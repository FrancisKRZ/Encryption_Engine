`timescale 1ns / 1ps

module SPIController_TB();

    // Parameters
    localparam CLK_PERIOD = 10;  // 100MHz system clock
    localparam DATA_WIDTH = 8;
    
    // Test signals
    reg                     tb_clk;
    reg                     tb_rst;
    reg  [DATA_WIDTH-1:0]   tb_data_in;
    reg                     tb_start;
    wire [DATA_WIDTH-1:0]   tb_data_out;
    wire                    tb_done;
    wire                    tb_spi_mosi;
    reg                     tb_spi_miso;
    wire                    tb_spi_clk;
    wire                    tb_spi_cs;
    reg  [7:0]             tb_clk_div;
    wire                    tb_busy;
    
    // Test storage
    reg [DATA_WIDTH-1:0] expected_rx_data;
    reg [DATA_WIDTH-1:0] received_data;
    integer bit_count;
    
    // Instantiate UUT
    SPIController #(
        .DATA_WIDTH(DATA_WIDTH),
        .CPOL(0),
        .CPHA(0)
    ) UUT (
        .i_clk(tb_clk),
        .i_rst(tb_rst),
        .i_data_in(tb_data_in),
        .i_start(tb_start),
        .o_data_out(tb_data_out),
        .o_done(tb_done),
        .o_spi_mosi(tb_spi_mosi),
        .i_spi_miso(tb_spi_miso),
        .o_spi_clk(tb_spi_clk),
        .o_spi_cs(tb_spi_cs),
        .i_clk_div(tb_clk_div),
        .o_busy(tb_busy)
    );
    
    // Clock generation
    initial begin
        tb_clk = 0;
        forever #(CLK_PERIOD/2) tb_clk = ~tb_clk;
    end
    
    // MISO generation process
    always @(posedge tb_spi_clk) begin
        if (!tb_spi_cs && bit_count < DATA_WIDTH) begin
            tb_spi_miso <= expected_rx_data[DATA_WIDTH-1];
            expected_rx_data <= {expected_rx_data[DATA_WIDTH-2:0], 1'b0};
            bit_count <= bit_count + 1;
        end
    end
    
    // Test stimulus
    initial begin
        // Initialize
        $display("Starting SPI Controller Testbench...");
        initialize_signals();
        
        // Test 1: Basic transmission
        $display("\nTest 1: Basic SPI transmission");
        perform_basic_transmission(8'hA5, 8'h5A);
        
        // Test 2: Back-to-back transmissions
        $display("\nTest 2: Back-to-back transmissions");
        perform_back_to_back_transmissions();
        
        // End simulation
        #(CLK_PERIOD*10);
        $display("\nTestbench completed successfully!");
        $finish;
    end
    
    // Tasks
    task initialize_signals;
        begin
            tb_rst = 1;
            tb_data_in = 0;
            tb_start = 0;
            tb_spi_miso = 0;
            tb_clk_div = 8'd4;
            bit_count = 0;
            
            #(CLK_PERIOD*2);
            tb_rst = 0;
            #(CLK_PERIOD);
        end
    endtask
    
    task perform_basic_transmission;
    input [DATA_WIDTH-1:0] tx_data;
    input [DATA_WIDTH-1:0] rx_data;
    integer i;
    begin
        // Reset bit counter and expected data
        bit_count = 0;
        expected_rx_data = rx_data;
        
        // Start transmission
        @(posedge tb_clk);
        tb_data_in = tx_data;
        tb_start = 1;
        
        @(posedge tb_clk);
        tb_start = 0;

        // Monitor SPI signals
        for (i = 0; i < DATA_WIDTH; i = i + 1) begin
            // Wait for clock edges
            @(posedge tb_spi_clk);
            if (tb_spi_mosi !== tx_data[DATA_WIDTH-1-i]) begin
                $display("Error: MOSI mismatch at bit %d. Expected: %b, Got: %b",
                         i, tx_data[DATA_WIDTH-1-i], tb_spi_mosi);
                $stop;
            end
        end

        // Wait for completion
        @(posedge tb_done);

        // Verify received data
        if (tb_data_out !== rx_data) begin
            $display("Error: Received data %h does not match expected %h", 
                     tb_data_out, rx_data);
            $stop;
        end else begin
            $display("Success: Received correct data %h", tb_data_out);
        end

        #(CLK_PERIOD*5);
    end
endtask

    
    task perform_back_to_back_transmissions;
        begin
            perform_basic_transmission(8'h55, 8'hAA);
            perform_basic_transmission(8'h33, 8'hCC);
            perform_basic_transmission(8'h0F, 8'hF0);
        end
    endtask

    // Dump waveforms
    initial begin
        $dumpfile("spi_controller_tb.vcd");
        $dumpvars(0, SPIController_TB);
    end

endmodule