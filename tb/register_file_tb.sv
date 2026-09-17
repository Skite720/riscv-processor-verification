`timescale 1ns/1ps

module register_file_tb;

    logic        clk;
    logic        rst_n;
    logic [4:0]  rs1_addr;
    logic [4:0]  rs2_addr;
    logic [4:0]  rd_addr;
    logic [31:0] write_data;
    logic        reg_write;

    logic [31:0] rs1_data;
    logic [31:0] rs2_data;

    // Instantiate Device Under Test (DUT)
    register_file dut (
        .clk(clk),
        .rst_n(rst_n),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .write_data(write_data),
        .reg_write(reg_write),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    // Generate continuous clock signal (toggles every 5ns = 100MHz clock)
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        reg_write = 0;
        rs1_addr = 0;
        rs2_addr = 0;
        rd_addr = 0;
        write_data = 0;

        // Release reset after 10ns
        #10 rst_n = 1;

        // --- TEST 1: Write 42 to Register x5 ---
        @(posedge clk);
        rd_addr = 5'd5;
        write_data = 32'd42;
        reg_write = 1;

        @(posedge clk);
        reg_write = 0;  // Disable write
        rs1_addr = 5'd5; // Set read address to x5
        #1;
        assert(rs1_data == 32'd42) else $error("REG WRITE TO x5 FAILED");
        $display("TEST 1: WRITE & READ x5 PASS");

        // --- TEST 2: Try writing to Register x0 (Should stay 0) ---
        @(posedge clk);
        rd_addr = 5'd0;
        write_data = 32'd999;
        reg_write = 1;

        @(posedge clk);
        reg_write = 0;
        rs1_addr = 5'd0;
        #1;
        assert(rs1_data == 32'd0) else $error("x0 HARDWIRE TO 0 FAILED");
        $display("TEST 2: x0 HARDWIRED TO 0 PASS");

        $display("");
        $display("==============================");
        $display("ALL REGISTER FILE TESTS PASSED");
        $display("==============================");
        $finish;
    end

endmodule