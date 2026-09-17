module instruction_memory (
    input  logic [31:0] address,
    output logic [31:0] instruction
);

    logic [31:0] memory [0:255];

    initial begin
        // addi x5, x0, 10
        memory[0] = 32'h00A00293;

        // addi x6, x0, 20
        memory[1] = 32'h01400313;

        // add x7, x5, x6
        memory[2] = 32'h006283B3;

        // NOP
        memory[3] = 32'h00000013;
    end

    assign instruction = memory[address[9:2]];

endmodule