`timescale 1ns/1ps
`default_nettype none
`include "riscv_defs.vh"

//------------------------------------------------------------------------------
// ID/EX pipeline register.
// Flush inserts a NOP/control-zero bubble. Stall holds current values.
//------------------------------------------------------------------------------
module id_ex_reg (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        stall_i,
    input  wire        flush_i,

    input  wire [31:0] id_pc_i,
    input  wire [31:0] id_pc4_i,
    input  wire [31:0] id_instr_i,
    input  wire [31:0] id_rs1_data_i,
    input  wire [31:0] id_rs2_data_i,
    input  wire [31:0] id_imm_i,
    input  wire [4:0]  id_rs1_addr_i,
    input  wire [4:0]  id_rs2_addr_i,
    input  wire [4:0]  id_rd_addr_i,
    input  wire [6:0]  id_opcode_i,
    input  wire [2:0]  id_funct3_i,
    input  wire [6:0]  id_funct7_i,

    input  wire        id_reg_write_i,
    input  wire        id_mem_read_i,
    input  wire        id_mem_write_i,
    input  wire [1:0]  id_mem_size_i,
    input  wire        id_mem_sign_ext_i,
    input  wire [1:0]  id_wb_sel_i,
    input  wire [3:0]  id_alu_op_i,
    input  wire        id_alu_src_imm_i,
    input  wire [1:0]  id_op_a_sel_i,
    input  wire        id_branch_i,
    input  wire        id_jump_i,
    input  wire        id_jalr_i,
    input  wire        id_is_lui_i,
    input  wire        id_is_auipc_i,
    input  wire        id_is_conv_i,
    input  wire        id_conv_init_i,
    input  wire        id_illegal_i,

    output reg  [31:0] ex_pc_o,
    output reg  [31:0] ex_pc4_o,
    
    output reg  [31:0] ex_rs1_data_o,
    output reg  [31:0] ex_rs2_data_o,
    output reg  [31:0] ex_imm_o,
    output reg  [4:0]  ex_rs1_addr_o,
    output reg  [4:0]  ex_rs2_addr_o,
    output reg  [4:0]  ex_rd_addr_o,
    
    
    

    output reg         ex_reg_write_o,
    output reg         ex_mem_read_o,
    output reg         ex_mem_write_o,
    output reg  [1:0]  ex_mem_size_o,
    output reg         ex_mem_sign_ext_o,
    output reg  [1:0]  ex_wb_sel_o,
    output reg  [3:0]  ex_alu_op_o,
    output reg         ex_alu_src_imm_o,
    
    output reg         ex_jump_o,
    output reg         ex_jalr_o,
    
    
    output reg         ex_is_conv_o,
    output reg         ex_conv_init_o
    
);
  
  reg  [31:0] ex_instr_o;
  reg  [6:0]  ex_opcode_o;
  reg  [2:0]  ex_funct3_o;
  reg  [6:0]  ex_funct7_o;
  reg  [1:0]  ex_op_a_sel_o;
  reg         ex_branch_o;
   reg         ex_is_lui_o;
   reg         ex_is_auipc_o;
   reg         ex_illegal_o;
    always @(posedge clk) begin
        if (!rst_n) begin
            ex_pc_o           <= 32'h00000000;
            ex_pc4_o          <= 32'h00000004;
            ex_instr_o        <= `RISCV_NOP;
            ex_rs1_data_o     <= 32'h00000000;
            ex_rs2_data_o     <= 32'h00000000;
            ex_imm_o          <= 32'h00000000;
            ex_rs1_addr_o     <= 5'd0;
            ex_rs2_addr_o     <= 5'd0;
            ex_rd_addr_o      <= 5'd0;
            ex_opcode_o       <= `OPCODE_OP_IMM;
            ex_funct3_o       <= 3'b000;
            ex_funct7_o       <= 7'b0000000;
            ex_reg_write_o    <= 1'b0;
            ex_mem_read_o     <= 1'b0;
            ex_mem_write_o    <= 1'b0;
            ex_mem_size_o     <= `MEM_WORD;
            ex_mem_sign_ext_o <= 1'b1;
            ex_wb_sel_o       <= `WB_ALU;
            ex_alu_op_o       <= `ALU_ADD;
            ex_alu_src_imm_o  <= 1'b0;
            ex_op_a_sel_o     <= `OP_A_RS1;
            ex_branch_o       <= 1'b0;
            ex_jump_o         <= 1'b0;
            ex_jalr_o         <= 1'b0;
            ex_is_lui_o       <= 1'b0;
            ex_is_auipc_o     <= 1'b0;
            ex_is_conv_o      <= 1'b0;
            ex_conv_init_o    <= 1'b0;
            ex_illegal_o      <= 1'b0;
        end else if (flush_i) begin
            ex_pc_o           <= 32'h00000000;
            ex_pc4_o          <= 32'h00000004;
            ex_instr_o        <= `RISCV_NOP;
            ex_rs1_data_o     <= 32'h00000000;
            ex_rs2_data_o     <= 32'h00000000;
            ex_imm_o          <= 32'h00000000;
            ex_rs1_addr_o     <= 5'd0;
            ex_rs2_addr_o     <= 5'd0;
            ex_rd_addr_o      <= 5'd0;
            ex_opcode_o       <= `OPCODE_OP_IMM;
            ex_funct3_o       <= 3'b000;
            ex_funct7_o       <= 7'b0000000;
            ex_reg_write_o    <= 1'b0;
            ex_mem_read_o     <= 1'b0;
            ex_mem_write_o    <= 1'b0;
            ex_mem_size_o     <= `MEM_WORD;
            ex_mem_sign_ext_o <= 1'b1;
            ex_wb_sel_o       <= `WB_ALU;
            ex_alu_op_o       <= `ALU_ADD;
            ex_alu_src_imm_o  <= 1'b0;
            ex_op_a_sel_o     <= `OP_A_RS1;
            ex_branch_o       <= 1'b0;
            ex_jump_o         <= 1'b0;
            ex_jalr_o         <= 1'b0;
            ex_is_lui_o       <= 1'b0;
            ex_is_auipc_o     <= 1'b0;
            ex_is_conv_o      <= 1'b0;
            ex_conv_init_o    <= 1'b0;
            ex_illegal_o      <= 1'b0;
        end else if (stall_i) begin
            ex_pc_o           <= ex_pc_o;
            ex_pc4_o          <= ex_pc4_o;
            ex_instr_o        <= ex_instr_o;
            ex_rs1_data_o     <= ex_rs1_data_o;
            ex_rs2_data_o     <= ex_rs2_data_o;
            ex_imm_o          <= ex_imm_o;
            ex_rs1_addr_o     <= ex_rs1_addr_o;
            ex_rs2_addr_o     <= ex_rs2_addr_o;
            ex_rd_addr_o      <= ex_rd_addr_o;
            ex_opcode_o       <= ex_opcode_o;
            ex_funct3_o       <= ex_funct3_o;
            ex_funct7_o       <= ex_funct7_o;
            ex_reg_write_o    <= ex_reg_write_o;
            ex_mem_read_o     <= ex_mem_read_o;
            ex_mem_write_o    <= ex_mem_write_o;
            ex_mem_size_o     <= ex_mem_size_o;
            ex_mem_sign_ext_o <= ex_mem_sign_ext_o;
            ex_wb_sel_o       <= ex_wb_sel_o;
            ex_alu_op_o       <= ex_alu_op_o;
            ex_alu_src_imm_o  <= ex_alu_src_imm_o;
            ex_op_a_sel_o     <= ex_op_a_sel_o;
            ex_branch_o       <= ex_branch_o;
            ex_jump_o         <= ex_jump_o;
            ex_jalr_o         <= ex_jalr_o;
            ex_is_lui_o       <= ex_is_lui_o;
            ex_is_auipc_o     <= ex_is_auipc_o;
            ex_is_conv_o      <= ex_is_conv_o;
            ex_conv_init_o    <= ex_conv_init_o;
            ex_illegal_o      <= ex_illegal_o;
        end else begin
            ex_pc_o           <= id_pc_i;
            ex_pc4_o          <= id_pc4_i;
            ex_instr_o        <= id_instr_i;
            ex_rs1_data_o     <= id_rs1_data_i;
            ex_rs2_data_o     <= id_rs2_data_i;
            ex_imm_o          <= id_imm_i;
            ex_rs1_addr_o     <= id_rs1_addr_i;
            ex_rs2_addr_o     <= id_rs2_addr_i;
            ex_rd_addr_o      <= id_rd_addr_i;
            ex_opcode_o       <= id_opcode_i;
            ex_funct3_o       <= id_funct3_i;
            ex_funct7_o       <= id_funct7_i;
            ex_reg_write_o    <= id_reg_write_i;
            ex_mem_read_o     <= id_mem_read_i;
            ex_mem_write_o    <= id_mem_write_i;
            ex_mem_size_o     <= id_mem_size_i;
            ex_mem_sign_ext_o <= id_mem_sign_ext_i;
            ex_wb_sel_o       <= id_wb_sel_i;
            ex_alu_op_o       <= id_alu_op_i;
            ex_alu_src_imm_o  <= id_alu_src_imm_i;
            ex_op_a_sel_o     <= id_op_a_sel_i;
            ex_branch_o       <= id_branch_i;
            ex_jump_o         <= id_jump_i;
            ex_jalr_o         <= id_jalr_i;
            ex_is_lui_o       <= id_is_lui_i;
            ex_is_auipc_o     <= id_is_auipc_i;
            ex_is_conv_o      <= id_is_conv_i;
            ex_conv_init_o    <= id_conv_init_i;
            ex_illegal_o      <= id_illegal_i;
        end
    end

endmodule

`default_nettype wire
