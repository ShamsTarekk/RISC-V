`timescale 1ns/1ps
`default_nettype none
`include "riscv_defs.vh"

module tb_imm_gen;
    reg  [31:0] instr;
    wire [31:0] imm;
    integer pass_count;
    integer fail_count;

    imm_gen dut (
        .instr_i(instr),
        .imm_o(imm)
    );

    task check;
        input condition;
        input [255:0] name;
        begin
            if (condition) begin
                $display("PASS: %0s", name);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: %0s", name);
                $display("      instr=%h imm=%h", instr, imm);
                fail_count = fail_count + 1;
            end
        end
    endtask

    function [31:0] enc_i;
        input [11:0] imm12;
        input [4:0] rs1;
        input [2:0] funct3;
        input [4:0] rd;
        input [6:0] opcode;
        begin
            enc_i = {imm12, rs1, funct3, rd, opcode};
        end
    endfunction

    function [31:0] enc_s;
        input [11:0] imm12;
        input [4:0] rs2;
        input [4:0] rs1;
        input [2:0] funct3;
        begin
            enc_s = {imm12[11:5], rs2, rs1, funct3, imm12[4:0], `OPCODE_STORE};
        end
    endfunction

    function [31:0] enc_b;
        input [12:0] imm13;
        input [4:0] rs2;
        input [4:0] rs1;
        input [2:0] funct3;
        begin
            enc_b = {imm13[12], imm13[10:5], rs2, rs1, funct3, imm13[4:1], imm13[11], `OPCODE_BRANCH};
        end
    endfunction

    function [31:0] enc_u;
        input [19:0] imm20;
        input [4:0] rd;
        input [6:0] opcode;
        begin
            enc_u = {imm20, rd, opcode};
        end
    endfunction

    function [31:0] enc_j;
        input [20:0] imm21;
        input [4:0] rd;
        begin
            enc_j = {imm21[20], imm21[10:1], imm21[11], imm21[19:12], rd, `OPCODE_JAL};
        end
    endfunction

    initial begin
        $dumpfile("sim/tb_imm_gen.vcd");
        $dumpvars(0, tb_imm_gen);
        pass_count = 0;
        fail_count = 0;

        instr = enc_i(12'hfff, 5'd2, 3'b000, 5'd1, `OPCODE_OP_IMM); #1;
        check(imm == 32'hffffffff, "I-type sign extends -1");

        instr = enc_i(12'h010, 5'd2, 3'b000, 5'd1, `OPCODE_OP_IMM); #1;
        check(imm == 32'h00000010, "I-type positive immediate");

        instr = enc_s(12'hff8, 5'd3, 5'd4, 3'b010); #1;
        check(imm == 32'hfffffff8, "S-type sign extends -8");

        instr = enc_b(13'h1ffc, 5'd2, 5'd1, 3'b000); #1;
        check(imm == 32'hfffffffc, "B-type sign extends -4 and keeps bit0 zero");

        instr = enc_u(20'h12345, 5'd5, `OPCODE_LUI); #1;
        check(imm == 32'h12345000, "U-type immediate shifts left 12");

        instr = enc_j(21'h00800, 5'd1); #1;
        check(imm == 32'h00000800, "J-type positive offset 0x800");

        if (fail_count == 0)
            $display("ALL tb_imm_gen CHECKS PASSED. pass=%0d", pass_count);
        else
            $display("tb_imm_gen FAILED. fail=%0d pass=%0d", fail_count, pass_count);
        $finish;
    end
endmodule

`default_nettype wire
