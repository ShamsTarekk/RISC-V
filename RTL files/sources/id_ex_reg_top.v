`include "id_stage.v"
`include "id_ex_reg.v"
`include "regfile.v"

// integration of the id_stage and the id_ex_reg

module id_ex_reg_top (
  input clk, rst_n,
    input  wire [31:0] id_pc_i,
    input  wire [31:0] id_pc4_i,
    input  wire [31:0] id_instr_i,
  	input  wire        flush_i,
  //input write enable to the register file coming from the mem and wb 
  input wire reg_write, 
  //inputs coming from write back to register file: distination addr and wb data 
  input wire [4:0] rd_addr, 
  input wire [31:0] wb_data,

//     // From register file read ports
//     input  wire [31:0] rs1_data_i,
//     input  wire [31:0] rs2_data_i,

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
  
  
  //signals from id_stage to id_ex_reg
  
      // To register file read ports
  wire [4:0]  rs1_addr_o_w;
  wire [4:0]  rs2_addr_o_w;

    // Datapath outputs toward ID/EX register
  wire [31:0] idex_pc_o_w;
  wire [31:0] idex_pc4_o_w;
  wire [31:0] idex_instr_o_w;
  wire [31:0] idex_rs1_data_o_w;
  wire [31:0] idex_rs2_data_o_w;
  wire [31:0] idex_imm_o_w;
  wire [4:0]  idex_rs1_addr_o_w;
  wire [4:0]  idex_rs2_addr_o_w;
  wire [4:0]  idex_rd_addr_o_w;
  wire [6:0]  idex_opcode_o_w;
  wire [2:0]  idex_funct3_o_w;
  wire [6:0]  idex_funct7_o_w;

    // Control outputs toward ID/EX register
     wire        idex_reg_write_o_w;
     wire        idex_mem_read_o_w;
     wire        idex_mem_write_o_w;
  wire [1:0]  idex_mem_size_o_w;
     wire        idex_mem_sign_ext_o_w;
  wire [1:0]  idex_wb_sel_o_w;
  wire [3:0]  idex_alu_op_o_w;
     wire        idex_alu_src_imm_o_w;
  wire [1:0]  idex_op_a_sel_o_w;
     wire        idex_branch_o_w;
     wire        idex_jump_o_w;
     wire        idex_jalr_o_w;
     wire        idex_is_lui_o_w;
     wire        idex_is_auipc_o_w;
     wire        idex_is_conv_o_w;
     wire        idex_conv_init_o_w;
  wire        idex_illegal_o_w;
  wire [2:0] branch_type_o_w;
     wire halt_signal_w;
  wire [31:0] rs1_data_i; 
  wire [31:0] rs2_data_i;
  
  //id_stage instance
  
  
   id_stage id_stage_inst(
     
     //inputs
     .id_pc_i(id_pc_i),
     .id_pc4_i(id_pc4_i),
     .id_instr_i(id_instr_i),
     .reg_write(reg_write),

    // From register file read ports
     .rs1_data_i(rs1_data_i),
     .rs2_data_i(rs2_data_i),
     
     //outputs

    // To register file read ports
     .rs1_addr_o(rs1_addr_o_w),
     .rs2_addr_o(rs2_addr_o_w),

    // Datapath outputs toward ID/EX register
    .idex_pc_o(idex_pc_o_w),
    .idex_pc4_o(idex_pc4_o_w),
    .idex_instr_o(idex_instr_o_w),
    .idex_rs1_data_o(idex_rs1_data_o_w),
    .idex_rs2_data_o(idex_rs2_data_o_w),
    .idex_imm_o(idex_imm_o_w),
    .idex_rs1_addr_o(idex_rs1_addr_o_w),
    .idex_rs2_addr_o(idex_rs2_addr_o_w),
    .idex_rd_addr_o(idex_rd_addr_o_w),
     .idex_opcode_o(idex_opcode_o_w),
     .idex_funct3_o(idex_funct3_o_w),
     .idex_funct7_o(idex_funct7_o_w),

    // Control outputs toward ID/EX register
     .idex_reg_write_o(idex_reg_write_o_w),
     .idex_mem_read_o(idex_mem_read_o_w),
     .idex_mem_write_o(idex_mem_write_o_w),
     .idex_mem_size_o(idex_mem_size_o_w),
     .idex_mem_sign_ext_o(idex_mem_sign_ext_o_w),
     .idex_wb_sel_o(idex_wb_sel_o_w),
     .idex_alu_op_o(idex_alu_op_o_w),
     .idex_alu_src_imm_o(idex_alu_src_imm_o_w),
     .idex_op_a_sel_o(idex_op_a_sel_o_w),
     .idex_branch_o(idex_branch_o_w),
     .idex_jump_o(idex_jump_o_w),
     .idex_jalr_o(idex_jalr_o_w),
     .idex_is_lui_o(idex_is_lui_o_w),
     .idex_is_auipc_o(idex_is_auipc_o_w),
     .idex_is_conv_o(idex_is_conv_o_w),
     .idex_conv_init_o(idex_conv_init_o_w),
     .idex_illegal_o(idex_illegal_o_w),
     .branch_type_o(branch_type_o_w),
     .halt_signal(halt_signal_w)
);
  
  //register file instance 
  regfile regfile_inst
  ( 
    .clk(clk), 
    .rst_n(rst_n), 
    //inputs from wb stage 
    .we(reg_write), 
    .rd_addr(rd_addr), 
    .rd_data(wb_data), 
    //inputs from the decoder stage 
    .a_addr(rs1_addr_o_w), 
    .b_addr(rs2_addr_o_w), 
    //outputs to the decoder stage 
    .a_data(rs1_data_i), 
    .b_data(rs2_data_i) );
  
   id_ex_reg id_ex_reg_inst (
     //inputs
     .clk(clk),
    .rst_n(rst_n),
    .stall_i(halt_signal_w),
    .flush_i(flush_i),

    .id_pc_i(idex_pc_o_w),
    .id_pc4_i(idex_pc4_o_w),
    .id_instr_i(idex_instr_o_w),
    .id_rs1_data_i(idex_rs1_data_o_w),
    .id_rs2_data_i(idex_rs2_data_o_w),
    .id_imm_i(idex_imm_o_w),
    .id_rs1_addr_i(idex_rs1_addr_o_w),
    .id_rs2_addr_i(idex_rs2_addr_o_w),
    .id_rd_addr_i(idex_rd_addr_o_w),
    .id_opcode_i(idex_opcode_o_w),
    .id_funct3_i(idex_funct3_o_w),
    .id_funct7_i(idex_funct7_o_w),

    .id_reg_write_i(idex_reg_write_o_w),
    .id_mem_read_i(idex_mem_read_o_w),
    .id_mem_write_i(idex_mem_write_o_w),
    .id_mem_size_i(idex_mem_size_o_w),
    .id_mem_sign_ext_i(idex_mem_sign_ext_o_w),
    .id_wb_sel_i(idex_wb_sel_o_w),
    .id_alu_op_i(idex_alu_op_o_w),
    .id_alu_src_imm_i(idex_alu_src_imm_o_w),
    .id_op_a_sel_i(idex_op_a_sel_o_w),
    .id_branch_i(idex_branch_o_w),
    .id_jump_i(idex_jump_o_w),
    .id_jalr_i(idex_jalr_o_w),
    .id_is_lui_i(idex_is_lui_o_w),
    .id_is_auipc_i(idex_is_auipc_o_w),
    .id_is_conv_i(idex_is_conv_o_w),
    .id_conv_init_i(idex_conv_init_o_w),
    .id_illegal_i(idex_illegal_o_w),
     
     //outputs

    .ex_pc_o(ex_pc_o),
    .ex_pc4_o(ex_pc4_o),
    
    .ex_rs1_data_o(ex_rs1_data_o),
    .ex_rs2_data_o(ex_rs2_data_o),
    .ex_imm_o(ex_imm_o),
    .ex_rs1_addr_o(ex_rs1_addr_o),
    .ex_rs2_addr_o(ex_rs2_addr_o),
    .ex_rd_addr_o(ex_rd_addr_o),
    
    
    

    .ex_reg_write_o(ex_reg_write_o),
    .ex_mem_read_o(ex_mem_read_o),
    .ex_mem_write_o(ex_mem_write_o),
    .ex_mem_size_o(ex_mem_size_o),
    .ex_mem_sign_ext_o(ex_mem_sign_ext_o),
    .ex_wb_sel_o(ex_wb_sel_o),
    .ex_alu_op_o(ex_alu_op_o),
    .ex_alu_src_imm_o(ex_alu_src_imm_o),
    
    .ex_jump_o(ex_jump_o),
    .ex_jalr_o(ex_jalr_o),
    
    
    .ex_is_conv_o(ex_is_conv_o),
    .ex_conv_init_o(ex_conv_init_o)
    
);
  
endmodule