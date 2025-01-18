`timescale 1ns / 1ps

module tb_FIFO_RAM;

    // Parameters for the FIFO
    parameter WIDTH = 8;
    parameter DEPTH = 256;

    // Testbench signals
    reg i_clk;
    reg i_rst;
    reg [WIDTH-1:0] i_wr_data;
    reg i_wr_en;
    reg i_rd_en;
    wire [WIDTH-1:0] o_rd_data;
    wire o_empty;
    wire o_full;

    // Instantiate the FIFO RAM module
    FIFO_RAM #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) uut (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_wr_data(i_wr_data),
        .i_wr_en(i_wr_en),
        .i_rd_en(i_rd_en),
        .o_rd_data(o_rd_data),
        .o_empty(o_empty),
        .o_full(o_full)
    );

    // Clock generation
    always begin
        #5 i_clk = ~i_clk; // 100 MHz clock
    end

    // Test procedure
    initial begin
        // Initialize signals
        i_clk = 0;
        i_rst = 0;
        i_wr_data = 8'h00;
        i_wr_en = 0;
        i_rd_en = 0;

        // Reset FIFO
        #10 i_rst = 1;
        #10 i_rst = 0;

        // Test case 1: Write to FIFO
        $display("Test Case 1: Write to FIFO");
        i_wr_data = 8'hAA;
        i_wr_en = 1;
        #10 i_wr_en = 0;

        // Test case 2: Read from FIFO
        $display("Test Case 2: Read from FIFO");
        i_rd_en = 1;
        #10 i_rd_en = 0;
        if (o_rd_data !== 8'hAA) begin
            $display("Error: Expected 8'hAA, got %h", o_rd_data);
        end

        // Test case 3: FIFO full condition
        $display("Test Case 3: FIFO full condition");
        // Fill FIFO to max depth (write DEPTH times)
        i_wr_en = 1;
        for (integer i = 0; i < DEPTH; i = i + 1) begin
            i_wr_data = i;
            #10;
        end
        if (!o_full) begin
            $display("Error: FIFO should be full but o_full is %b", o_full);
        end
        i_wr_en = 0;

        // Test case 4: FIFO read after full
        $display("Test Case 4: FIFO read after full");
        i_rd_en = 1;
        #10 i_rd_en = 0;
        if (o_rd_data !== 8'h00) begin
            $display("Error: Expected 8'h00, got %h", o_rd_data);
        end

        // Test case 5: FIFO empty condition
        $display("Test Case 5: FIFO empty condition");
        // Empty FIFO by reading DEPTH times
        for (integer i = 0; i < DEPTH; i = i + 1) begin
            i_rd_en = 1;
            #10 i_rd_en = 0;
        end
        if (!o_empty) begin
            $display("Error: FIFO should be empty but o_empty is %b", o_empty);
        end

        // Test case 6: Attempt to read from empty FIFO
        $display("Test Case 6: Read from empty FIFO");
        i_rd_en = 1;
        #10 i_rd_en = 0;
        if (o_rd_data !== 8'h00) begin
            $display("Error: Expected 8'h00, got %h", o_rd_data);
        end

        $stop; // End simulation
    end

endmodule
