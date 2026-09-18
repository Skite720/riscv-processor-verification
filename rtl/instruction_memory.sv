module instruction_memory #(
    parameter PROGRAM_FILE = "programs/program.hex"
)(
    input logic [31:0] address,
    output logic [31:0] instruction
);

    logic [31:0] memory [0:255];

    integer i;

    initial begin

        for (i = 0; i < 256; i = i + 1)
            memory[i] = 32'h00000013;

        $readmemh(PROGRAM_FILE, memory);

    end

    assign instruction = memory[address[9:2]];

endmodule