`timescale 1ns/1ps
`default_nettype none
`include "riscv_defs.vh"

module tb_id_stage;
    reg  [31:0] id_pc;
    reg  [31:0] id_pc4;
    reg  [31:0] id_instr;
    reg  [31:0] rs1_data;
    reg  [31:0] rs2_data;

    wire [4:0] rs1_addr;
    wire [4:0] rs2_addr;
    wire [31:0] idex_pc;
    wire [31:0] idex_pc4;
    wire [31:0] idex_instr;
    wire [31:0] idex_rs1_data;
    wire [31:0] idex_rs2_data;
    wire [31:0] idex_imm;
    wire [4:0] idex_rs1_addr;
    wire [4:0] idex_rs2_addr;
    wire [4:0] idex_rd_addr;
    wire [6:0] idex_opcode;
    wire [2:0] idex_funct3;
    wire [6:0] idex_funct7;
    wire idex_reg_write;
    wire idex_mem_read;
    wire idex_mem_write;
    wire [1:0] idex_mem_size;
    wire idex_mem_sign_ext;
    wire [1:0] idex_wb_sel;
    wire [3:0] idex_alu_op;
    wire idex_alu_src_imm;
    wire [1:0] idex_op_a_sel;
    wire idex_branch;
    wire idex_jump;
    wire idex_jalr;
    wire idex_is_lui;
    wire idex_is_auipc;
    wire idex_is_conv;
    wire idex_conv_init;
    wire idex_illegal;

    integer pass_count;
    integer fail_count;

    id_stage dut (
        .id_pc_i(id_pc), .id_pc4_i(id_pc4), .id_instr_i(id_instr),
        .rs1_data_i(rs1_data), .rs2_data_i(rs2_data),
        .rs1_addr_o(rs1_addr), .rs2_addr_o(rs2_addr),
        .idex_pc_o(idex_pc), .idex_pc4_o(idex_pc4), .idex_instr_o(idex_instr),
        .idex_rs1_data_o(idex_rs1_data), .idex_rs2_data_o(idex_rs2_data), .idex_imm_o(idex_imm),
        .idex_rs1_addr_o(idex_rs1_addr), .idex_rs2_addr_o(idex_rs2_addr), .idex_rd_addr_o(idex_rd_addr),
        .idex_opcode_o(idex_opcode), .idex_funct3_o(idex_funct3), .idex_funct7_o(idex_funct7),
        .idex_reg_write_o(idex_reg_write), .idex_mem_read_o(idex_mem_read), .idex_mem_write_o(idex_mem_write),
        .idex_mem_size_o(idex_mem_size), .idex_mem_sign_ext_o(idex_mem_sign_ext), .idex_wb_sel_o(idex_wb_sel),
        .idex_alu_op_o(idex_alu_op), .idex_alu_src_imm_o(idex_alu_src_imm), .idex_op_a_sel_o(idex_op_a_sel),
        .idex_branch_o(idex_branch), .idex_jump_o(idex_jump), .idex_jalr_o(idex_jalr),
        .idex_is_lui_o(idex_is_lui), .idex_is_auipc_o(idex_is_auipc), .idex_is_conv_o(idex_is_conv),
        .idex_conv_init_o(idex_conv_init), .idex_illegal_o(idex_illegal)
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
                $display("      instr=%h opcode=%b rd=%0d rs1=%0d rs2=%0d imm=%h regW=%b memR=%b memW=%b wb=%b alu=%b immSel=%b br=%b jump=%b jalr=%b conv=%b init=%b",
                    id_instr, idex_opcode, idex_rd_addr, idex_rs1_addr, idex_rs2_addr, idex_imm,
                    idex_reg_write, idex_mem_read, idex_mem_write, idex_wb_sel, idex_alu_op,
                    idex_alu_src_imm, idex_branch, idex_jump, idex_jalr, idex_is_conv, idex_conv_init);
                fail_count = fail_count + 1;
            end
        end
    endtask

    function [31:0] enc_r;
        input [6:0] funct7;
        input [4:0] rs2;
        input [4:0] rs1;
        input [2:0] funct3;
        input [4:0] rd;
        begin
            enc_r = {funct7, rs2, rs1, funct3, rd, `OPCODE_OP};
        end
    endfunction

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

    function [31:0] enc_custom;
        input [6:0] funct7;
        input [4:0] rs2;
        input [4:0] rs1;
        input [4:0] rd;
        begin
            enc_custom = {funct7, rs2, rs1, 3'b000, rd, `OPCODE_CUSTOM0};
        end
    endfunction

    initial begin
        $dumpfile("sim/tb_id_stage.vcd");
        $dumpvars(0, tb_id_stage);
        id_pc = 32'h00000100;
        id_pc4 = 32'h00000104;
        rs1_data = 32'h11111111;
        rs2_data = 32'h22222222;
        pass_count = 0;
        fail_count = 0;

        id_instr = enc_r(7'b0000000, 5'd2, 5'd1, 3'b000, 5'd3); #1;
        check(idex_opcode == `OPCODE_OP && idex_rd_addr == 5'd3 && idex_rs1_addr == 5'd1 && idex_rs2_addr == 5'd2 && idex_reg_write && idex_alu_op == `ALU_ADD && idex_rs1_data == rs1_data && idex_rs2_data == rs2_data, "ID ADD field/control decode");

        id_instr = enc_i(12'hfff, 5'd6, 3'b000, 5'd5, `OPCODE_OP_IMM); #1;
        check(rs1_addr == 5'd6 && idex_rd_addr == 5'd5 && idex_imm == 32'hffffffff && idex_reg_write && idex_alu_src_imm && idex_alu_op == `ALU_ADD, "ID ADDI decode with sign-extended immediate");

        id_instr = enc_i(12'h004, 5'd10, 3'b010, 5'd11, `OPCODE_LOAD); #1;
        check(idex_mem_read && idex_reg_write && idex_wb_sel == `WB_MEM && idex_mem_size == `MEM_WORD && idex_imm == 32'h00000004, "ID LW decode");

        id_instr = enc_s(12'h008, 5'd12, 5'd10, 3'b010); #1;
        check(idex_mem_write && !idex_reg_write && idex_mem_size == `MEM_WORD && idex_rs1_addr == 5'd10 && idex_rs2_addr == 5'd12 && idex_imm == 32'h00000008, "ID SW decode");

        id_instr = enc_b(13'h0008, 5'd2, 5'd1, 3'b000); #1;
        check(idex_branch && !idex_reg_write && idex_funct3 == 3'b000 && idex_imm == 32'h00000008, "ID BEQ decode");

        id_instr = enc_u(20'h12345, 5'd7, `OPCODE_LUI); #1;
        check(idex_is_lui && idex_reg_write && idex_op_a_sel == `OP_A_ZERO && idex_imm == 32'h12345000, "ID LUI decode");

        id_instr = enc_custom(7'b0000001, 5'd9, 5'd8, 5'd10); #1;
        check(idex_is_conv && idex_conv_init && idex_wb_sel == `WB_CONV && idex_reg_write && idex_rs1_addr == 5'd8 && idex_rs2_addr == 5'd9 && idex_rd_addr == 5'd10, "ID custom-0 Conv init decode");

        if (fail_count == 0)
            $display("ALL tb_id_stage CHECKS PASSED. pass=%0d", pass_count);
        else
            $display("tb_id_stage FAILED. fail=%0d pass=%0d", fail_count, pass_count);
        $finish;
    end
endmodule

`default_nettype wire
