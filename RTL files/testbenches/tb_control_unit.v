`timescale 1ns/1ps
`default_nettype none
`include "riscv_defs.vh"

module tb_control_unit;
    reg  [6:0] opcode;
    reg  [2:0] funct3;
    reg  [6:0] funct7;

    wire reg_write;
    wire mem_read;
    wire mem_write;
    wire [1:0] mem_size;
    wire mem_sign_ext;
    wire [1:0] wb_sel;
    wire [3:0] alu_op;
    wire alu_src_imm;
    wire [1:0] op_a_sel;
    wire branch;
    wire jump;
    wire jalr;
    wire is_lui;
    wire is_auipc;
    wire is_conv;
    wire conv_init;
    wire illegal;

    integer pass_count;
    integer fail_count;

    control_unit dut (
        .opcode_i(opcode), .funct3_i(funct3), .funct7_i(funct7),
        .reg_write_o(reg_write), .mem_read_o(mem_read), .mem_write_o(mem_write),
        .mem_size_o(mem_size), .mem_sign_ext_o(mem_sign_ext), .wb_sel_o(wb_sel),
        .alu_op_o(alu_op), .alu_src_imm_o(alu_src_imm), .op_a_sel_o(op_a_sel),
        .branch_o(branch), .jump_o(jump), .jalr_o(jalr), .is_lui_o(is_lui),
        .is_auipc_o(is_auipc), .is_conv_o(is_conv), .conv_init_o(conv_init),
        .illegal_o(illegal)
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
                $display("      op=%b f3=%b f7=%b regW=%b memR=%b memW=%b wb=%b alu=%b imm=%b opa=%b br=%b jump=%b jalr=%b conv=%b init=%b illegal=%b",
                    opcode, funct3, funct7, reg_write, mem_read, mem_write, wb_sel, alu_op,
                    alu_src_imm, op_a_sel, branch, jump, jalr, is_conv, conv_init, illegal);
                fail_count = fail_count + 1;
            end
        end
    endtask

    task apply;
        input [6:0] op;
        input [2:0] f3;
        input [6:0] f7;
        begin
            opcode = op;
            funct3 = f3;
            funct7 = f7;
            #1;
        end
    endtask

    initial begin
        $dumpfile("sim/tb_control_unit.vcd");
        $dumpvars(0, tb_control_unit);
        pass_count = 0;
        fail_count = 0;

        apply(`OPCODE_OP, 3'b000, 7'b0000000);
        check(reg_write && !alu_src_imm && alu_op == `ALU_ADD && wb_sel == `WB_ALU && !illegal, "R ADD decode");

        apply(`OPCODE_OP, 3'b000, 7'b0100000);
        check(reg_write && alu_op == `ALU_SUB && !illegal, "R SUB decode");

        apply(`OPCODE_OP_IMM, 3'b101, 7'b0100000);
        check(reg_write && alu_src_imm && alu_op == `ALU_SRA && !illegal, "I SRAI decode");

        apply(`OPCODE_LOAD, 3'b010, 7'b0000000);
        check(reg_write && mem_read && !mem_write && wb_sel == `WB_MEM && mem_size == `MEM_WORD && mem_sign_ext && alu_src_imm, "LW decode");

        apply(`OPCODE_LOAD, 3'b100, 7'b0000000);
        check(reg_write && mem_read && wb_sel == `WB_MEM && mem_size == `MEM_BYTE && !mem_sign_ext, "LBU decode");

        apply(`OPCODE_STORE, 3'b010, 7'b0000000);
        check(!reg_write && !mem_read && mem_write && mem_size == `MEM_WORD && alu_op == `ALU_ADD && alu_src_imm, "SW decode");

        apply(`OPCODE_BRANCH, 3'b000, 7'b0000000);
        check(!reg_write && branch && !jump && alu_op == `ALU_SUB, "BEQ/branch decode");

        apply(`OPCODE_JAL, 3'b000, 7'b0000000);
        check(reg_write && jump && !jalr && op_a_sel == `OP_A_PC && alu_src_imm, "JAL decode");

        apply(`OPCODE_JALR, 3'b000, 7'b0000000);
        check(reg_write && jump && jalr && op_a_sel == `OP_A_RS1 && alu_src_imm, "JALR decode");

        apply(`OPCODE_LUI, 3'b000, 7'b0000000);
        check(reg_write && is_lui && op_a_sel == `OP_A_ZERO && alu_src_imm, "LUI decode");

        apply(`OPCODE_AUIPC, 3'b000, 7'b0000000);
        check(reg_write && is_auipc && op_a_sel == `OP_A_PC && alu_src_imm, "AUIPC decode");

        apply(`OPCODE_CUSTOM0, 3'b000, 7'b0000001);
        check(reg_write && is_conv && conv_init && wb_sel == `WB_CONV && !illegal, "custom-0 Conv init decode");

        apply(`OPCODE_CUSTOM0, 3'b000, 7'b0000000);
        check(reg_write && is_conv && !conv_init && wb_sel == `WB_CONV && !illegal, "custom-0 Conv accumulate decode");

        apply(`OPCODE_MISC_MEM, 3'b000, 7'b0000000);
        check(!reg_write && !mem_read && !mem_write && !branch && !jump && !illegal, "FENCE as NOP-like legal decode");

        apply(`OPCODE_SYSTEM, 3'b000, 7'b0000000);
        check(!reg_write && !mem_read && !mem_write && !branch && !jump && !illegal, "SYSTEM as NOP/trap-like legal decode");

        if (fail_count == 0)
            $display("ALL tb_control_unit CHECKS PASSED. pass=%0d", pass_count);
        else
            $display("tb_control_unit FAILED. fail=%0d pass=%0d", fail_count, pass_count);
        $finish;
    end
endmodule

`default_nettype wire
