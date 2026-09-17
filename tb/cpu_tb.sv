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

    // Clock
    always #5 clk = ~clk;

    initial begin

        clk = 1'b0;
        reset = 1'b1;

        // Hold reset
        #12;

        reset = 1'b0;

        // Run several instructions
        #50;

        $display("");
        $display("==============================");
        $display("CPU SIMULATION COMPLETE");
        $display("==============================");

        $finish;
    end

    always @(posedge clk) begin
        if (!reset) begin
            $display(
                "PC = %0d | Instruction = %h",
                debug_pc,
                debug_instruction
            );
        end
    end

endmodule