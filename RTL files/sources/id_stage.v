`timescale 1ns/1ps
`default_nettype none
`include "riscv_defs.vh"
`include "imm_gen.v"
`include "control_unit.v"

//------------------------------------------------------------------------------
// ID stage: instruction field extraction + regfile read addresses + immediate
// generation + control decode.
//
// Important integration note:
// This module does NOT instantiate regfile.v. It outputs rs1/rs2 addresses and
// receives rs1/rs2 data from the top-level regfile instance. This avoids
// fighting with Person 2's regfile implementation.
//------------------------------------------------------------------------------
module id_stage (
    input  wire [31:0] id_pc_i,
    input  wire [31:0] id_pc4_i,
    input  wire [31:0] id_instr_i,
	input wire reg_write,
    // From register file read ports
    input  wire [31:0] rs1_data_i,
    input  wire [31:0] rs2_data_i,
  	

    // To register file read ports
    output wire [4:0]  rs1_addr_o,
    output wire [4:0]  rs2_addr_o,

    // Datapath outputs toward ID/EX register
    output wire [31:0] idex_pc_o,
    output wire [31:0] idex_pc4_o,
    output wire [31:0] idex_instr_o,
    output wire [31:0] idex_rs1_data_o,
    output wire [31:0] idex_rs2_data_o,
    output wire [31:0] idex_imm_o,
    output wire [4:0]  idex_rs1_addr_o,
    output wire [4:0]  idex_rs2_addr_o,
    output wire [4:0]  idex_rd_addr_o,
    output wire [6:0]  idex_opcode_o,
    output wire [2:0]  idex_funct3_o,
    output wire [6:0]  idex_funct7_o,

    // Control outputs toward ID/EX register
    output wire        idex_reg_write_o,
    output wire        idex_mem_read_o,
    output wire        idex_mem_write_o,
    output wire [1:0]  idex_mem_size_o,
    output wire        idex_mem_sign_ext_o,
    output wire [1:0]  idex_wb_sel_o,
    output wire [3:0]  idex_alu_op_o,
    output wire        idex_alu_src_imm_o,
    output wire [1:0]  idex_op_a_sel_o,
    output wire        idex_branch_o,
    output wire        idex_jump_o,
    output wire        idex_jalr_o,
    output wire        idex_is_lui_o,
    output wire        idex_is_auipc_o,
    output wire        idex_is_conv_o,
    output wire        idex_conv_init_o,
    output wire        idex_illegal_o,
  output wire [2:0] branch_type_o,
  output wire halt_signal
);

    wire [6:0] opcode;
    wire [4:0] rd;
    wire [2:0] funct3;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [6:0] funct7;
    wire [31:0] imm;

    assign opcode = id_instr_i[6:0];
    assign rd     = id_instr_i[11:7];
    assign funct3 = id_instr_i[14:12];
    assign rs1    = id_instr_i[19:15];
    assign rs2    = id_instr_i[24:20];
    assign funct7 = id_instr_i[31:25];

    assign rs1_addr_o = rs1;
    assign rs2_addr_o = rs2;

    imm_gen u_imm_gen (
        .instr_i (id_instr_i),
        .imm_o   (imm)
    );

    control_unit u_control_unit (
        .opcode_i       (opcode),
        .funct3_i       (funct3),
        .funct7_i       (funct7),
        .reg_write_o    (idex_reg_write_o),
        .mem_read_o     (idex_mem_read_o),
        .mem_write_o    (idex_mem_write_o),
        .mem_size_o     (idex_mem_size_o),
        .mem_sign_ext_o (idex_mem_sign_ext_o),
        .wb_sel_o       (idex_wb_sel_o),
        .alu_op_o       (idex_alu_op_o),
        .alu_src_imm_o  (idex_alu_src_imm_o),
        .op_a_sel_o     (idex_op_a_sel_o),
        .branch_o       (idex_branch_o),
        .jump_o         (idex_jump_o),
        .jalr_o         (idex_jalr_o),
        .is_lui_o       (idex_is_lui_o),
        .is_auipc_o     (idex_is_auipc_o),
        .is_conv_o      (idex_is_conv_o),
        .conv_init_o    (idex_conv_init_o),
      .illegal_o      (idex_illegal_o),
      .branch_type_o(branch_type_o),
      .halt_o(halt_signal)
    );

    assign idex_pc_o       = id_pc_i;
    assign idex_pc4_o      = id_pc4_i;
    assign idex_instr_o    = id_instr_i;
    assign idex_rs1_data_o = rs1_data_i;
    assign idex_rs2_data_o = rs2_data_i;
    assign idex_imm_o      = imm;
    assign idex_rs1_addr_o = rs1;
    assign idex_rs2_addr_o = rs2;
    assign idex_rd_addr_o  = rd;
    assign idex_opcode_o   = opcode;
    assign idex_funct3_o   = funct3;
    assign idex_funct7_o   = funct7;

endmodule

`default_nettype wire
