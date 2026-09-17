module control_unit (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,

    output logic reg_write,
    output logic alu_src,
    output logic mem_write,
    output logic mem_to_reg,
    output logic branch,
    output logic [2:0] alu_control
);

    localparam logic [6:0] OP_RTYPE  = 7'b0110011;
    localparam logic [6:0] OP_ITYPE  = 7'b0010011;
    localparam logic [6:0] OP_LOAD   = 7'b0000011;
    localparam logic [6:0] OP_STORE  = 7'b0100011;
    localparam logic [6:0] OP_BRANCH = 7'b1100011;

    localparam logic [2:0] ALU_ADD = 3'b000;
    localparam logic [2:0] ALU_SUB = 3'b001;
    localparam logic [2:0] ALU_AND = 3'b010;
    localparam logic [2:0] ALU_OR  = 3'b011;
    localparam logic [2:0] ALU_XOR = 3'b100;
    localparam logic [2:0] ALU_SLT = 3'b101;

    always_comb begin
        reg_write   = 1'b0;
        alu_src     = 1'b0;
        mem_write   = 1'b0;
        mem_to_reg  = 1'b0;
        branch      = 1'b0;
        alu_control = ALU_ADD;

        case (opcode)

            OP_RTYPE: begin
                reg_write = 1'b1;

                case (funct3)
                    3'b000: alu_control = ALU_ADD;
                    3'b111: alu_control = ALU_AND;
                    3'b110: alu_control = ALU_OR;
                    3'b100: alu_control = ALU_XOR;
                    3'b010: alu_control = ALU_SLT;
                    default: alu_control = ALU_ADD;
                endcase
            end

            OP_ITYPE: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;

                case (funct3)
                    3'b000: alu_control = ALU_ADD; // ADDI
                    3'b111: alu_control = ALU_AND; // ANDI
                    3'b110: alu_control = ALU_OR;  // ORI
                    3'b100: alu_control = ALU_XOR; // XORI
                    3'b010: alu_control = ALU_SLT; // SLTI
                    default: alu_control = ALU_ADD;
                endcase
            end

            OP_LOAD: begin
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                mem_to_reg = 1'b1;
                alu_control = ALU_ADD;
            end

            OP_STORE: begin
                alu_src    = 1'b1;
                mem_write  = 1'b1;
                alu_control = ALU_ADD;
            end

            OP_BRANCH: begin
                branch      = 1'b1;
                alu_control = ALU_SUB;
            end

            default: begin
                reg_write   = 1'b0;
                alu_src     = 1'b0;
                mem_write   = 1'b0;
                mem_to_reg  = 1'b0;
                branch      = 1'b0;
                alu_control = ALU_ADD;
            end

        endcase
    end

endmodule