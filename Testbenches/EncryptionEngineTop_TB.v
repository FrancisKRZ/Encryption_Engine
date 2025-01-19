module EncryptionEngineTop_TB;

    // Testbench signals
    reg i_clk;
    reg i_rst;
    reg i_spi_miso;
    reg [127:0] i_key; // Example 128-bit key
    reg i_start;
    wire o_spi_mosi;
    wire o_spi_clk;
    wire o_spi_cs;
    wire o_w5500_rst;
    wire [7:0] o_encrypted_data;
    wire o_done;

    // Instantiate the top module
    EncryptionEngineTop UUT (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_spi_miso(i_spi_miso),
        .i_key(i_key),
        .i_start(i_start),
        .o_spi_mosi(o_spi_mosi),
        .o_spi_clk(o_spi_clk),
        .o_spi_cs(o_spi_cs),
        .o_w5500_rst(o_w5500_rst),
        .o_encrypted_data(o_encrypted_data),
        .o_done(o_done)
    );

    // Clock generation
    always begin
        #5 i_clk = ~i_clk;
    end

    // Stimuli
    initial begin
        // Initialize signals
        i_clk = 0;
        i_rst = 1;
        i_spi_miso = 8'b00000000;
        i_key = 128'h0123456789abcdef0123456789abcdef;
        i_start = 0;

        // Apply reset
        #10 i_rst = 0;
        
        // Start the encryption process
        #10 i_start = 1;
        i_spi_miso = 8'hAA;  // Simulating SPI data

        // Continue simulation for a while
        #50 i_start = 0;

        // Wait for done signal
        wait (o_done == 1);

        // Check the encrypted data (this can be done by comparing with expected values manually)
        $display("Encrypted data: %h", o_encrypted_data);

        // End simulation
        #100 $finish;
    end


endmodule
