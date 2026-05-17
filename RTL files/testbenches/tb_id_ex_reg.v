`timescale 1ns/1ps
`default_nettype none
`include "riscv_defs.vh"

module tb_id_ex_reg;
    reg clk;
    reg rst_n;
    reg stall;
    reg flush;

    reg [31:0] id_pc;
    reg [31:0] id_pc4;
    reg [31:0] id_instr;
    reg [31:0] id_rs1_data;
    reg [31:0] id_rs2_data;
    reg [31:0] id_imm;
    reg [4:0]  id_rs1_addr;
    reg [4:0]  id_rs2_addr;
    reg [4:0]  id_rd_addr;
    reg [6:0]  id_opcode;
    reg [2:0]  id_funct3;
    reg [6:0]  id_funct7;
    reg        id_reg_write;
    reg        id_mem_read;
    reg        id_mem_write;
    reg [1:0]  id_mem_size;
    reg        id_mem_sign_ext;
    reg [1:0]  id_wb_sel;
    reg [3:0]  id_alu_op;
    reg        id_alu_src_imm;
    reg [1:0]  id_op_a_sel;
    reg        id_branch;
    reg        id_jump;
    reg        id_jalr;
    reg        id_is_lui;
    reg        id_is_auipc;
    reg        id_is_conv;
    reg        id_conv_init;
    reg        id_illegal;

    wire [31:0] ex_pc;
    wire [31:0] ex_pc4;
    wire [31:0] ex_instr;
    wire [31:0] ex_rs1_data;
    wire [31:0] ex_rs2_data;
    wire [31:0] ex_imm;
    wire [4:0]  ex_rs1_addr;
    wire [4:0]  ex_rs2_addr;
    wire [4:0]  ex_rd_addr;
    wire [6:0]  ex_opcode;
    wire [2:0]  ex_funct3;
    wire [6:0]  ex_funct7;
    wire        ex_reg_write;
    wire        ex_mem_read;
    wire        ex_mem_write;
    wire [1:0]  ex_mem_size;
    wire        ex_mem_sign_ext;
    wire [1:0]  ex_wb_sel;
    wire [3:0]  ex_alu_op;
    wire        ex_alu_src_imm;
    wire [1:0]  ex_op_a_sel;
    wire        ex_branch;
    wire        ex_jump;
    wire        ex_jalr;
    wire        ex_is_lui;
    wire        ex_is_auipc;
    wire        ex_is_conv;
    wire        ex_conv_init;
    wire        ex_illegal;

    integer pass_count;
    integer fail_count;

    id_ex_reg dut (
        .clk(clk), .rst_n(rst_n), .stall_i(stall), .flush_i(flush),
        .id_pc_i(id_pc), .id_pc4_i(id_pc4), .id_instr_i(id_instr),
        .id_rs1_data_i(id_rs1_data), .id_rs2_data_i(id_rs2_data), .id_imm_i(id_imm),
        .id_rs1_addr_i(id_rs1_addr), .id_rs2_addr_i(id_rs2_addr), .id_rd_addr_i(id_rd_addr),
        .id_opcode_i(id_opcode), .id_funct3_i(id_funct3), .id_funct7_i(id_funct7),
        .id_reg_write_i(id_reg_write), .id_mem_read_i(id_mem_read), .id_mem_write_i(id_mem_write),
        .id_mem_size_i(id_mem_size), .id_mem_sign_ext_i(id_mem_sign_ext), .id_wb_sel_i(id_wb_sel),
        .id_alu_op_i(id_alu_op), .id_alu_src_imm_i(id_alu_src_imm), .id_op_a_sel_i(id_op_a_sel),
        .id_branch_i(id_branch), .id_jump_i(id_jump), .id_jalr_i(id_jalr),
        .id_is_lui_i(id_is_lui), .id_is_auipc_i(id_is_auipc), .id_is_conv_i(id_is_conv),
        .id_conv_init_i(id_conv_init), .id_illegal_i(id_illegal),
        .ex_pc_o(ex_pc), .ex_pc4_o(ex_pc4), .ex_instr_o(ex_instr),
        .ex_rs1_data_o(ex_rs1_data), .ex_rs2_data_o(ex_rs2_data), .ex_imm_o(ex_imm),
        .ex_rs1_addr_o(ex_rs1_addr), .ex_rs2_addr_o(ex_rs2_addr), .ex_rd_addr_o(ex_rd_addr),
        .ex_opcode_o(ex_opcode), .ex_funct3_o(ex_funct3), .ex_funct7_o(ex_funct7),
        .ex_reg_write_o(ex_reg_write), .ex_mem_read_o(ex_mem_read), .ex_mem_write_o(ex_mem_write),
        .ex_mem_size_o(ex_mem_size), .ex_mem_sign_ext_o(ex_mem_sign_ext), .ex_wb_sel_o(ex_wb_sel),
        .ex_alu_op_o(ex_alu_op), .ex_alu_src_imm_o(ex_alu_src_imm), .ex_op_a_sel_o(ex_op_a_sel),
        .ex_branch_o(ex_branch), .ex_jump_o(ex_jump), .ex_jalr_o(ex_jalr),
        .ex_is_lui_o(ex_is_lui), .ex_is_auipc_o(ex_is_auipc), .ex_is_conv_o(ex_is_conv),
        .ex_conv_init_o(ex_conv_init), .ex_illegal_o(ex_illegal)
    );

    always #5 clk = ~clk;

    task check;
        input condition;
        input [255:0] name;
        begin
            if (condition) begin
                $display("PASS: %0s", name);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: %0s", name);
                $display("      ex_instr=%h ex_pc=%h ex_rd=%0d regW=%b memR=%b memW=%b br=%b jump=%b conv=%b init=%b wb=%b alu=%b",
                    ex_instr, ex_pc, ex_rd_addr, ex_reg_write, ex_mem_read, ex_mem_write,
                    ex_branch, ex_jump, ex_is_conv, ex_conv_init, ex_wb_sel, ex_alu_op);
                fail_count = fail_count + 1;
            end
        end
    endtask

    task drive_bundle;
        input [31:0] pc;
        input [31:0] instr;
        input [4:0] rd;
        input regwrite;
        input memread;
        input memwrite;
        input branch;
        input jump;
        input conv;
        begin
            id_pc = pc;
            id_pc4 = pc + 32'd4;
            id_instr = instr;
            id_rs1_data = 32'h11110000 + pc;
            id_rs2_data = 32'h22220000 + pc;
            id_imm = 32'h00000010;
            id_rs1_addr = 5'd1;
            id_rs2_addr = 5'd2;
            id_rd_addr = rd;
            id_opcode = instr[6:0];
            id_funct3 = instr[14:12];
            id_funct7 = instr[31:25];
            id_reg_write = regwrite;
            id_mem_read = memread;
            id_mem_write = memwrite;
            id_mem_size = `MEM_WORD;
            id_mem_sign_ext = 1'b1;
            id_wb_sel = conv ? `WB_CONV : (memread ? `WB_MEM : `WB_ALU);
            id_alu_op = branch ? `ALU_SUB : `ALU_ADD;
            id_alu_src_imm = memread | memwrite;
            id_op_a_sel = `OP_A_RS1;
            id_branch = branch;
            id_jump = jump;
            id_jalr = 1'b0;
            id_is_lui = 1'b0;
            id_is_auipc = 1'b0;
            id_is_conv = conv;
            id_conv_init = conv;
            id_illegal = 1'b0;
        end
    endtask

    initial begin
        $dumpfile("sim/tb_id_ex_reg.vcd");
        $dumpvars(0, tb_id_ex_reg);
        clk = 0;
        rst_n = 0;
        stall = 0;
        flush = 0;
        pass_count = 0;
        fail_count = 0;
        drive_bundle(32'h0, 32'h00500093, 5'd1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0);

        @(posedge clk); #1;
        check(ex_instr == `RISCV_NOP && !ex_reg_write && !ex_mem_read && !ex_mem_write && !ex_branch && !ex_jump && !ex_is_conv, "reset inserts NOP/control-zero bubble");

        rst_n = 1;
        drive_bundle(32'h00000020, 32'h00500093, 5'd1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0);
        @(posedge clk); #1;
        check(ex_pc == 32'h00000020 && ex_instr == 32'h00500093 && ex_rd_addr == 5'd1 && ex_reg_write && ex_wb_sel == `WB_ALU, "normal load captures ID bundle");

        stall = 1;
        drive_bundle(32'h00000040, 32'h0000a203, 5'd4, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0);
        @(posedge clk); #1;
        check(ex_pc == 32'h00000020 && ex_instr == 32'h00500093 && ex_rd_addr == 5'd1 && !ex_mem_read, "stall holds previous ID/EX bundle");

        stall = 0;
        flush = 1;
        @(posedge clk); #1;
        check(ex_instr == `RISCV_NOP && !ex_reg_write && !ex_mem_read && !ex_mem_write && !ex_branch && !ex_jump && !ex_is_conv, "flush inserts NOP/control-zero bubble");

        // This RTL gives flush priority over stall.
        stall = 1;
        flush = 1;
        drive_bundle(32'h00000080, 32'h02b5048b, 5'd9, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1);
        @(posedge clk); #1;
        check(ex_instr == `RISCV_NOP && !ex_is_conv && !ex_reg_write, "flush priority over stall");

        if (fail_count == 0)
            $display("ALL tb_id_ex_reg CHECKS PASSED. pass=%0d", pass_count);
        else
            $display("tb_id_ex_reg FAILED. fail=%0d pass=%0d", fail_count, pass_count);
        $finish;
    end
endmodule

`default_nettype wire
