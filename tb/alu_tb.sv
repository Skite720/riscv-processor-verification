`timescale 1ns/1ps

module alu_tb;

    logic [31:0] a;
    logic [31:0] b;
    logic [2:0] control;

    logic [31:0] result;
    logic zero;

    alu dut (
        .a(a),
        .b(b),
        .control(control),
        .result(result),
        .zero(zero)
    );

    localparam logic [2:0] ALU_ADD = 3'b000;
    localparam logic [2:0] ALU_SUB = 3'b001;
    localparam logic [2:0] ALU_AND = 3'b010;
    localparam logic [2:0] ALU_OR  = 3'b011;
    localparam logic [2:0] ALU_XOR = 3'b100;
    localparam logic [2:0] ALU_SLT = 3'b101;

    initial begin

        // ADD
        a = 10;
        b = 20;
        control = ALU_ADD;

        #1;

        assert(result == 30)
            else $error("ADD FAILED");

        $display("ADD: PASS");


        // SUB
        a = 20;
        b = 10;
        control = ALU_SUB;

        #1;

        assert(result == 10)
            else $error("SUB FAILED");

        $display("SUB: PASS");


        // AND
        a = 32'hFF00FF00;
        b = 32'h0F0F0F0F;
        control = ALU_AND;

        #1;

        assert(result == 32'h0F000F00)
            else $error("AND FAILED");

        $display("AND: PASS");


        // OR
        a = 32'hFF000000;
        b = 32'h000000FF;
        control = ALU_OR;

        #1;

        assert(result == 32'hFF0000FF)
            else $error("OR FAILED");

        $display("OR: PASS");


        // XOR
        a = 32'hAAAAAAAA;
        b = 32'h55555555;
        control = ALU_XOR;

        #1;

        assert(result == 32'hFFFFFFFF)
            else $error("XOR FAILED");

        $display("XOR: PASS");


        // Signed SLT
        a = 32'hFFFFFFFF;   // -1
        b = 1;
        control = ALU_SLT;

        #1;

        assert(result == 1)
            else $error("SLT FAILED");

        $display("SLT: PASS");


        // Zero flag
        a = 10;
        b = 10;
        control = ALU_SUB;

        #1;

        assert(zero == 1)
            else $error("ZERO FLAG FAILED");

        $display("ZERO FLAG: PASS");


        $display("");
        $display("==============================");
        $display("ALL ALU TESTS PASSED");
        $display("==============================");

        $finish;

    end

endmodule