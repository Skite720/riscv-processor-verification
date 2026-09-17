module alu (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [2:0] control,

    output logic [31:0] result,
    output logic zero
);

    localparam logic [2:0] ALU_ADD = 3'b000;
    localparam logic [2:0] ALU_SUB = 3'b001;
    localparam logic [2:0] ALU_AND = 3'b010;
    localparam logic [2:0] ALU_OR  = 3'b011;
    localparam logic [2:0] ALU_XOR = 3'b100;
    localparam logic [2:0] ALU_SLT = 3'b101;

    always_comb begin

        case (control)

            ALU_ADD:
                result = a + b;

            ALU_SUB:
                result = a - b;

            ALU_AND:
                result = a & b;

            ALU_OR:
                result = a | b;

            ALU_XOR:
                result = a ^ b;

            ALU_SLT:
                result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;

            default:
                result = 32'd0;

        endcase

    end

    assign zero = (result == 32'd0);

endmodule