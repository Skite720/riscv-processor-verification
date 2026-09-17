`timescale 1ns/1ps

module decoder_tb;

    logic [31:0] instr;
    logic [6:0]  opcode;
    logic [4:0]  rd;
    logic [2:0]  funct3;
    logic [4:0]  rs1;
    logic [4:0]  rs2;
    logic [6:0]  funct7;
    logic [31:0] imm_i;

    // Instantiate Device Under Test
    decoder dut (
        .instr(instr),
        .opcode(opcode),
        .rd(rd),
        .funct3(funct3),
        .rs1(rs1),
        .rs2(rs2),
        .funct7(funct7),
        .imm_i(imm_i)
    );

    initial begin
        // TEST 1: Decode "add x7, x5, x6" (Hex: 0x006283b3)
        instr = 32'h006283b3;
        #1;
        assert(opcode == 7'b0110011) else $error("Opcode decode failed");
        assert(rd == 5'd7)           else $error("rd decode failed");
        assert(rs1 == 5'd5)          else $error("rs1 decode failed");
        assert(rs2 == 5'd6)          else $error("rs2 decode failed");
        $display("TEST 1: R-TYPE ADD DECODE PASS");

        // TEST 2: Decode "addi x5, x5, 10" (Hex: 0x00a28293)iverilog -g2012 -o dec_sim.vvp rtl/decoder.sv tb/decoder_tb.sv
        instr = 32'h00a28293;
        #1;
        assert(opcode == 7'b0010011) else $error("I-type opcode failed");
        assert(rd == 5'd5)           else $error("I-type rd failed");
        assert(imm_i == 32'd10)      else $error("I-type immediate failed");
        $display("TEST 2: I-TYPE ADDI DECODE PASS");

        $display("");
        $display("==============================");
        $display("ALL DECODER TESTS PASSED");
        $display("==============================");
        $finish;
    end

endmodule