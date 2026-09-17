module cpu (
    input logic        clk,
    input logic        reset,

    output logic [31:0] debug_pc,
    output logic [31:0] debug_instruction
);

    // =========================================================
    // Program Counter
    // =========================================================

    logic [31:0] pc;
    logic [31:0] next_pc;

    program_counter pc_unit (
        .clk(clk),
        .reset(reset),
        .next_pc(next_pc),
        .pc(pc)
    );

    // =========================================================
    // Instruction Memory
    // =========================================================

    logic [31:0] instruction;

    instruction_memory imem (
        .address(pc),
        .instruction(instruction)
    );

    // =========================================================
    // Decoder
    // =========================================================

    logic [6:0] opcode;
    logic [4:0] rd;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [2:0] funct3;
    logic [6:0] funct7;

    decoder decoder_unit (
        .instr(instruction),
        .opcode(opcode),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .funct3(funct3),
        .funct7(funct7)
    );

    // =========================================================
    // Register File
    // =========================================================

    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
    logic [31:0] write_data;

    logic reg_write;

    register_file registers (
    .clk(clk),
    .rst_n(~reset),
    .rs1_addr(rs1),
    .rs2_addr(rs2),
    .rd_addr(rd),
    .write_data(write_data),
    .reg_write(reg_write),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data)
);

    // =========================================================
    // Immediate Generator
    // =========================================================

    logic [31:0] immediate;

    immediate_generator imm_gen (
        .instruction(instruction),
        .immediate(immediate)
    );

    // =========================================================
    // Control Unit
    // =========================================================

    logic alu_src;
    logic mem_write;
    logic mem_to_reg;
    logic branch;
    logic [2:0] alu_control;

    control_unit control (
        .opcode(opcode),
        .funct3(funct3),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .alu_control(alu_control)
    );

    // =========================================================
    // ALU
    // =========================================================

    logic [31:0] alu_input_b;
    logic [31:0] alu_result;
    logic alu_zero;

    assign alu_input_b = alu_src ? immediate : rs2_data;

    alu alu_unit (
        .a(rs1_data),
        .b(alu_input_b),
        .control(alu_control),
        .result(alu_result),
        .zero(alu_zero)
    );

    // =========================================================
    // Data Memory
    // =========================================================

    logic [31:0] memory_data;

    data_memory dmem (
        .clk(clk),
        .mem_write(mem_write),
        .address(alu_result),
        .write_data(rs2_data),
        .read_data(memory_data)
    );

    // =========================================================
    // Writeback
    // =========================================================

    assign write_data = mem_to_reg ? memory_data : alu_result;

    // =========================================================
    // PC Logic
    // =========================================================

    always_comb begin
        next_pc = pc + 32'd4;

        // Basic branch support
        if (branch && alu_zero)
            next_pc = pc + immediate;
    end

    // =========================================================
    // Debug Outputs
    // =========================================================

    assign debug_pc = pc;
    assign debug_instruction = instruction;

endmodule