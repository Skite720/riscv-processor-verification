module riscv_processor (
    input logic clk,
    input logic reset
);

    logic [31:0] debug_pc;
    logic [31:0] debug_instruction;

    cpu processor (
        .clk(clk),
        .reset(reset),
        .debug_pc(debug_pc),
        .debug_instruction(debug_instruction)
    );

endmodule