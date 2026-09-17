`timescale 1ns/1ps

module immediate_generator_tb;

    logic [31:0] instruction;
    logic [31:0] immediate;

    immediate_generator dut (
        .instruction(instruction),
        .immediate(immediate)
    );

    initial begin

        // addi x5, x0, 10
        instruction = 32'h00A00293;
        #1;

        assert(immediate == 32'd10)
            else $error("ADDI IMMEDIATE FAILED");

        $display("ADDI +10: PASS");

        // addi x5, x0, -5
        instruction = 32'hFFB00293;
        #1;

        assert(immediate == 32'hFFFFFFFB)
            else $error("NEGATIVE IMMEDIATE FAILED");

        $display("ADDI -5: PASS");

        $display("");
        $display("==============================");
        $display("ALL IMMEDIATE TESTS PASSED");
        $display("==============================");

        $finish;
    end

endmodule