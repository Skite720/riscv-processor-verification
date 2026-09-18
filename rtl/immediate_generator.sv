// module immediate_generator (
//     input  logic [31:0] instruction,
//     output logic [31:0] immediate
// );

//     logic [6:0] opcode;

//     assign opcode = instruction[6:0];

//     always_comb begin
//         case (opcode)

//             // I-type instructions: ADDI, ANDI, ORI, XORI, etc.
//             7'b0010011: begin
//                 immediate = {{20{instruction[31]}},
//                              instruction[31:20]};
//             end

//             // Load instructions: LW
//             7'b0000011: begin
//                 immediate = {{20{instruction[31]}},
//                              instruction[31:20]};
//             end

//             // Store instructions: SW
//             7'b0100011: begin
//                 immediate = {{20{instruction[31]}},
//                              instruction[31:25],
//                              instruction[11:7]};
//             end

//             // Branch instructions: BEQ, BNE, etc.
//             7'b1100011: begin
//                 immediate = {{19{instruction[31]}},
//                              instruction[31],
//                              instruction[7],
//                              instruction[30:25],
//                              instruction[11:8],
//                              1'b0};
//             end

//             default: begin
//                 immediate = 32'd0;
//             end

//         endcase
//     end

// endmodule


// module immediate_generator (
//     input  logic [31:0] instruction,
//     output logic [31:0] immediate
// );
//     assign immediate = {{20{instruction[31]}}, instruction[31:20]};
// endmodule

module immediate_generator (
    input  logic [31:0] instruction,
    output logic [31:0] immediate
);

    logic [6:0] opcode;
    assign opcode = instruction[6:0];

    localparam logic [6:0] OP_ITYPE  = 7'b0010011;
    localparam logic [6:0] OP_LOAD   = 7'b0000011;
    localparam logic [6:0] OP_STORE  = 7'b0100011; // 0x23
    localparam logic [6:0] OP_BRANCH = 7'b1100011;

    always_comb begin
        case (opcode)
            // I-Type (ADDI, LW, etc.)
            OP_ITYPE, OP_LOAD: begin
                immediate = {{20{instruction[31]}}, instruction[31:20]};
            end

            // S-Type (SW)
            OP_STORE: begin
                immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end

            // B-Type (BEQ)
            OP_BRANCH: begin
                immediate = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            end

            default: begin
                immediate = 32'd0;
            end
        endcase
    end

endmodule