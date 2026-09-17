module decoder (
    input  logic [31:0] instr,       // 32-bit RISC-V binary instruction word

    output logic [6:0]  opcode,      // Instruction type identifier (Bits 6:0)
    output logic [4:0]  rd,          // Destination register address (Bits 11:7)
    output logic [2:0]  funct3,      // Sub-operation code (Bits 14:12)
    output logic [4:0]  rs1,         // Source register 1 address (Bits 19:15)
    output logic [4:0]  rs2,         // Source register 2 address (Bits 24:20)
    output logic [6:0]  funct7,      // Extension operation code (Bits 31:25)
    output logic [31:0] imm_i        // 32-bit sign-extended immediate for I-type
);

    // Continuous wire slicing (Pure combinational routing)
    assign opcode = instr[6:0];
    assign rd     = instr[11:7];
    assign funct3 = instr[14:12];
    assign rs1    = instr[19:15];
    assign rs2    = instr[24:20];
    assign funct7 = instr[31:25];

    // Sign-extend 12-bit I-type immediate (instr[31:20]) to 32 bits
    assign imm_i = {{20{instr[31]}}, instr[31:20]};

endmodule
