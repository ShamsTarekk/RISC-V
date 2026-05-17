`include "mem_wb_integrated.v"
`include "ex_stage_ex_mem_reg.v"


//integration of ex_stage and ex_mem_reg

module ex_mem_stages_top (
    input clk,
    input rst_n,

    // 1. Inputs from ID/EX Pipeline Register
    input [31:0] ex_pc,
    input [31:0] ex_rs1_data,
    input [31:0] ex_rs2_data,
    input [31:0] ex_imm,
    input [4:0]  id_ex_rd_addr,
    
    // 2. Control Signals from ID Stage
    input [3:0]  alu_op,          
    input        alu_src_b_sel,   
    input        conv_start,   
    input        conv_init,   
    input [2:0]  branch_type,     
    input        is_jump,         
    input        is_jalr,         // Required for the target_base logic
    input        mem_read_e,
    input        mem_write_e,
    input        reg_write_e,
    input [1:0]  wb_sel_e,
    input [1:0]  mem_size_e,
    input        sign_ext_e,
  output reg [31:0] wb_data,
  output reg reg_write, 
  output reg [4:0] rd_addr,
  output reg conv_busy_o,
  output reg conv_done
);
  
  
  //signals from ex_mem to the mem_wb_stage

  wire [31:0] alu_result_m_w;      // Connects to alu_result_in
  wire [31:0] conv_result_m_w;     // Connects to conv_PE_result_in
  wire [31:0] out_pc_plus_4_m_w;   // Usually passed to wb_sel mux
  wire [31:0] rs2_data_m_w;        // Connects to rs2_data (store data)
  wire [4:0]  rd_addr_m_w;         // Connects to rd_addr_in
    
  wire        mem_read_m_w;        // Connects to mem_read
  wire        mem_write_m_w;       // Connects to mem_write
  wire        reg_write_m_w;       // Connects to reg_write_in
  wire [1:0]  wb_sel_m_w;          // Connects to wb_sel_in
  wire [1:0]  mem_size_m_w;        // Connects to mem_size
  wire       sign_ext_m_w;         // Connects to sign_ext
  wire conv_busy_out_w;

  
  
   ex_mem_top ex_mem_top_inst (
     
     //inputs
     .clk(clk),
     .rst_n(rst_n),

    // 1. Inputs from ID/EX Pipeline Register
     .ex_pc(ex_pc),
     .ex_rs1_data(ex_rs1_data),
     .ex_rs2_data(ex_rs2_data),
    .ex_imm(ex_imm),
     .id_ex_rd_addr(id_ex_rd_addr),
    
    // 2. Control Signals from ID Stage
     .alu_op(alu_op),          
     .alu_src_b_sel(alu_src_b_sel),   
     .conv_start(conv_start),   
     .conv_init(conv_init),   
     .branch_type(branch_type),     
     .is_jump(is_jump),         
     .is_jalr(is_jalr),         // Required for the target_base logic
     .mem_read_e(mem_read_e),
     .mem_write_e(mem_write_e),
     .reg_write_e(reg_write_e),
     .wb_sel_e(wb_sel_e),
     .mem_size_e(mem_size_e),
     .sign_ext_e(sign_ext_e),
     
     //outputs
     .alu_result_m(alu_result_m_w),      // Connects to alu_result_in
     .conv_result_m(conv_result_m_w),     // Connects to conv_PE_result_in
     .out_pc_plus_4_m(out_pc_plus_4_m_w),   // Usually passed to wb_sel mux
     .rs2_data_m(rs2_data_m_w),        // Connects to rs2_data (store data)
     .rd_addr_m(rd_addr_m_w),         // Connects to rd_addr_in
    
     .mem_read_m(mem_read_m_w),        // Connects to mem_read
     .mem_write_m(mem_write_m_w),       // Connects to mem_write
     .reg_write_m(reg_write_m_w),       // Connects to reg_write_in
     .wb_sel_m(wb_sel_m_w),          // Connects to wb_sel_in
     .mem_size_m(mem_size_m_w),        // Connects to mem_size
     .sign_ext_m(sign_ext_m_w),         // Connects to sign_ext
     .conv_busy_out(conv_busy_out_w),
     .conv_done_out(conv_done)

);
  
   mem_top mem_top_inst (
     
     //inputs
     .clk(clk), .rst_n(rst_n),
     .mem_read(mem_read_m_w), //used to read data from memory
     .mem_write(mem_read_m_w), //used to write data into memory
     .alu_result_in(alu_result_m_w), //contains result of the arithmetic operation or address to store the data in for Store/Load instructions
     .rs2_data(rs2_data_m_w), //data to store
     .reg_write_in(reg_write_m_w),
     .wb_sel_in(wb_sel_m_w),
     .rd_addr_in(rd_addr_m_w),
     .conv_PE_result_in(conv_result_m_w),
     .out_pc_plus_4_in(out_pc_plus_4_m_w),
     .mem_size(mem_size_m_w),
     .sign_ext(sign_ext_m_w),
     .conv_busy(conv_busy_out_w),

     //outputs
     .wb_data(wb_data),
     .reg_write(reg_write), 
     .conv_busy_o(conv_busy_o),
     .rd_addr(rd_addr));


  
  

endmodule