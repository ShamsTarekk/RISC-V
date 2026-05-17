`include "if_stage_id_reg.v"
`include "id_ex_reg_top.v"
`include "ex_mem_stages_top.v"


module riscv_top (
  
  //inputs of if_stage
    input  wire        clk,
    input  wire        rst_n,

    // Global pipeline controls
    input  wire        stall_i,// freeze PC while Conv-PE is busy
  	input wire 		   flush_i,
    input  wire        redirect_valid_i, // branch/JAL/JALR taken in EX
    input  wire [31:0] redirect_pc_i,
    input [3:0]  alu_op,          
    input        alu_src_b_sel,   
    input        conv_start,   
    input        conv_init, 
  	output   [31:0] id_pc_o,
  	output   [31:0] id_pc4_o,
  	output   [31:0] id_instr_o,
    output   [31:0] ex_pc_o,
    output   [31:0] ex_pc4_o,
    
    output   [31:0] ex_rs1_data_o,
    output   [31:0] ex_rs2_data_o,
    output   [31:0] ex_imm_o,
    output   [4:0]  ex_rs1_addr_o,
    output   [4:0]  ex_rs2_addr_o,
    output   [4:0]  ex_rd_addr_o,
    
    
    

    output          ex_mem_read_o,
    output          ex_mem_write_o,
    output   [1:0]  ex_mem_size_o,
    output          ex_mem_sign_ext_o,
    output   [1:0]  ex_wb_sel_o,
    output   [3:0]  ex_alu_op_o,
    output          ex_alu_src_imm_o,
    
    output          ex_jump_o,
    output          ex_jalr_o,
    
    
    output          ex_is_conv_o,
    output          ex_conv_init_o,
    output  [31:0] wb_data,
  	output  reg_write, 
  	output  [4:0] rd_addr,
  	output  conv_done,
  	output  conv_busy_o,
  output [2:0] branch_type


);
  
  
  //intermediate signals
  wire  [31:0] id_pc_o_w;
  wire  [31:0] id_pc4_o_w;
  wire  [31:0] id_instr_o_w;
  wire  [31:0] ex_pc_o_w;
  wire  [31:0] ex_pc4_o_w;

  wire  [31:0] ex_rs1_data_o_w;
  wire  [31:0] ex_rs2_data_o_w;
  wire  [31:0] ex_imm_o_w;
  wire  [4:0]  ex_rs1_addr_o_w;
  wire  [4:0]  ex_rs2_addr_o_w;
  wire  [4:0]  ex_rd_addr_o_w;

    
    

    wire         ex_reg_write_o_w;
    wire         ex_mem_read_o_w;
    wire         ex_mem_write_o_w;
  	wire  [1:0]  ex_mem_size_o_w;
    wire         ex_mem_sign_ext_o_w;
  	wire  [1:0]  ex_wb_sel_o_w;
  	wire  [3:0]  ex_alu_op_o_w;
    wire         ex_alu_src_imm_o_w;
    
    wire         ex_jump_o_w;
    wire         ex_jalr_o_w;
    
    
    wire         ex_is_conv_o_w;
    wire         ex_conv_init_o_w;
  	wire [31:0] wb_data_w;
  	wire reg_write_w; 
  	wire [4:0] rd_addr_w;
  	wire conv_done_w;
  	wire [2:0]  branch_type_w;
  	wire conv_busy_o_w;
	assign branch_type = branch_type_w;
  assign id_pc_o = id_pc_o_w;
  	assign id_pc4_o = id_pc4_o_w;
  	assign id_instr_o = id_instr_o_w;
    assign ex_pc_o = ex_pc_o_w;
    assign ex_pc4_o = ex_pc4_o_w;
    
    assign ex_rs1_data_o = ex_rs1_data_o_w;
    assign ex_rs2_data_o = ex_rs2_data_o_w;
    assign ex_imm_o = ex_imm_o_w;
    assign  ex_rs1_addr_o = ex_rs1_addr_o_w;
    assign  ex_rs2_addr_o = ex_rs2_addr_o_w;
    assign  ex_rd_addr_o = ex_rd_addr_o_w;
    
    
    

    assign ex_mem_read_o = ex_mem_read_o_w;
    assign ex_mem_write_o = ex_mem_write_o_w;
    assign  ex_mem_size_o = ex_mem_size_o_w;
    assign  ex_mem_sign_ext_o = ex_mem_sign_ext_o_w;
    assign  ex_wb_sel_o = ex_wb_sel_o_w;
    assign  ex_alu_op_o = ex_alu_op_o_w;
    assign  ex_alu_src_imm_o = ex_alu_src_imm_o_w;
    
    assign  ex_jump_o = ex_jump_o_w;
    assign  ex_jalr_o = ex_jalr_o_w;
    
    
    assign  ex_is_conv_o = ex_is_conv_o_w;
    assign  ex_conv_init_o = ex_conv_init_o_w;
    assign  wb_data = wb_data_w;
  	assign reg_write = reg_write_w;
  	assign rd_addr = rd_addr_w;
  	assign conv_done = conv_done_w;
  	assign conv_busy_o = conv_busy_o_w;


  
   if_stage_id_reg if_stage_id_reg_inst(
     //inputs
     .clk(clk),
     .rst_n(rst_n),

    // Global pipeline controls
    .stall_i(stall_i),// freeze PC while Conv-PE is busy
    .flush_i(flush_i),
    .redirect_valid_i(redirect_valid_i), // branch/JAL/JALR taken in EX
    .redirect_pc_i(redirect_pc_i),
     //outputs
    .id_pc_o(id_pc_o_w),
     .id_pc4_o(id_pc4_o_w),
     .id_instr_o(id_instr_o_w)

);
    
    
    
     id_ex_reg_top id_ex_reg_top_inst(
       //inputs
       .clk(clk), .rst_n(rst_n),
       .id_pc_i(id_pc_o_w),
       .id_pc4_i(id_pc4_o_w),
       .id_instr_i(id_instr_o_w),
       .flush_i(flush_i),
  //input write enable to the register file coming from the mem and wb 
      .reg_write(reg_write_w), 
  //inputs coming from write back to register file: distination addr and wb data 
      .rd_addr(rd_addr_w), 
      .wb_data(wb_data_w),

       //outputs

       .ex_pc_o(ex_pc_o_w),
       .ex_pc4_o(ex_pc4_o_w),
    
      .ex_rs1_data_o(ex_rs1_data_o_w),
      .ex_rs2_data_o(ex_rs2_data_o_w),
      .ex_imm_o(ex_imm_o_w),
      .ex_rs1_addr_o(ex_rs1_addr_o_w),
      .ex_rs2_addr_o(ex_rs2_addr_o_w),
      .ex_rd_addr_o(ex_rd_addr_o_w),
    
    
    

      .ex_reg_write_o(ex_reg_write_o_w),
      .ex_mem_read_o(ex_mem_read_o_w),
      .ex_mem_write_o(ex_mem_write_o_w),
      .ex_mem_size_o(ex_mem_size_o_w),
      .ex_mem_sign_ext_o(ex_mem_sign_ext_o_w),
      .ex_wb_sel_o(ex_wb_sel_o_w),
      .ex_alu_op_o(ex_alu_op_o_w),
      .ex_alu_src_imm_o(ex_alu_src_imm_o_w),
    
      .ex_jump_o(ex_jump_o_w),
      .ex_jalr_o(ex_jalr_o_w),
    
    
      .ex_is_conv_o(ex_is_conv_o_w),
      .ex_conv_init_o(ex_conv_init_o_w)
    
);
      
  
      
   ex_mem_stages_top ex_mem_stages_top_inst(
     .clk(clk),
     .rst_n(rst_n),

    // 1. Inputs from ID/EX Pipeline Register
     .ex_pc(ex_pc_o_w),
     .ex_rs1_data(ex_rs1_data_o_w),
     .ex_rs2_data(ex_rs2_data_o_w),
     .ex_imm(ex_imm_o_w),
     .id_ex_rd_addr(ex_rd_addr_o_w),
    
    // 2. Control Signals from ID Stage
     .alu_op(alu_op),          
     .alu_src_b_sel(alu_src_b_sel),   
     .conv_start(conv_start),   
     .conv_init(conv_init),   
     .is_jump(ex_jump_o_w),         
     .is_jalr(ex_jalr_o_w),         // Required for the target_base logic
     .mem_read_e(ex_mem_read_o_w),
     .mem_write_e(ex_mem_write_o_w),
     .reg_write_e(ex_reg_write_o_w),
     .wb_sel_e(ex_wb_sel_o_w),
     .mem_size_e(ex_mem_size_o_w),
     .sign_ext_e(ex_mem_sign_ext_o_w),
     .wb_data(wb_data_w),
     .reg_write(reg_write_w), 
     .rd_addr(rd_addr_w),
     .conv_busy_o(conv_busy_o_w),
     .conv_done(conv_done_w),
     .branch_type(branch_type_w)
);
  
endmodule
