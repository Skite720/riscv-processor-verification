`timescale 1ns/1ps

module cpu_tb;

    logic clk;
    logic reset;

    logic [31:0] debug_pc;
    logic [31:0] debug_instruction;


    cpu dut (
        .clk(clk),
        .reset(reset),
        .debug_pc(debug_pc),
        .debug_instruction(debug_instruction)
    );


    // 100 MHz simulation clock
    always #5 clk = ~clk;


    initial begin

        clk = 1'b0;

        reset = 1'b1;

        // Reset
        #12;

        reset = 1'b0;


        // Run CPU
        #180;


        // Print architectural state

        $display("REG x5  %0d", dut.registers.registers[5]);
        $display("REG x6  %0d", dut.registers.registers[6]);
        $display("REG x7  %0d", dut.registers.registers[7]);
        $display("REG x8  %0d", dut.registers.registers[8]);
        $display("REG x9  %0d", dut.registers.registers[9]);
        $display("REG x10 %0d", dut.registers.registers[10]);
        $display("REG x11 %0d", dut.registers.registers[11]);
        $display("REG x12 %0d", dut.registers.registers[12]);
        $display("REG x13 %0d", dut.registers.registers[13]);
        $display("REG x14 %0d", dut.registers.registers[14]);
        $display("REG x15 %0d", dut.registers.registers[15]);
        $display("REG x16 %0d", dut.registers.registers[16]);

        $display("MEM 0 %0d", dut.dmem.memory[0]);


        // -----------------------------
        // Self-checking assertions
        // -----------------------------

        if (dut.registers.registers[5] !== 32'd10)
            $fatal(1, "x5 mismatch");

        if (dut.registers.registers[6] !== 32'd20)
            $fatal(1, "x6 mismatch");

        if (dut.registers.registers[7] !== 32'd30)
            $fatal(1, "x7 mismatch");

        if (dut.registers.registers[8] !== 32'd20)
            $fatal(1, "x8 mismatch");

        if (dut.registers.registers[9] !== 32'd0)
            $fatal(1, "x9 mismatch");

        if (dut.registers.registers[10] !== 32'd30)
            $fatal(1, "x10 mismatch");

        if (dut.registers.registers[11] !== 32'd30)
            $fatal(1, "x11 mismatch");

        if (dut.registers.registers[12] !== 32'd1)
            $fatal(1, "x12 mismatch");

        if (dut.registers.registers[13] !== 32'd100)
            $fatal(1, "x13 mismatch");

        if (dut.registers.registers[14] !== 32'd100)
            $fatal(1, "x14 mismatch");


        // BEQ should skip x15

        if (dut.registers.registers[15] !== 32'd0)
            $fatal(1, "BEQ failed: x15 changed");


        // Branch target

        if (dut.registers.registers[16] !== 32'd42)
            $fatal(1, "Branch target failed");


        // Memory

        if (dut.dmem.memory[0] !== 32'd100)
            $fatal(1, "Memory mismatch");


        // x0 must remain zero

        if (dut.registers.registers[0] !== 32'd0)
            $fatal(1, "x0 is not zero");


        $display("");
        $display("TEST_PASS CPU integration regression");
        $display("");

        $finish;

    end


    // Instruction trace

    always @(posedge clk) begin

        if (!reset)

            $display(
                "TRACE PC=%0d INSTR=%h",
                debug_pc,
                debug_instruction
            );

    end

endmodule