`include "ex_stage.v"
`include "ex_mem_reg.v"


//integration of ex_stage and ex_mem_reg

module ex_mem_top (
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
    output reg [31:0] alu_result_m,      // Connects to alu_result_in
    output reg [31:0] conv_result_m,     // Connects to conv_PE_result_in
    output reg [31:0] out_pc_plus_4_m,   // Usually passed to wb_sel mux
    output reg [31:0] rs2_data_m,        // Connects to rs2_data (store data)
    output reg [4:0]  rd_addr_m,         // Connects to rd_addr_in
    
    output reg        mem_read_m,        // Connects to mem_read
    output reg        mem_write_m,       // Connects to mem_write
    output reg        reg_write_m,       // Connects to reg_write_in
    output reg [1:0]  wb_sel_m,          // Connects to wb_sel_in
    output reg [1:0]  mem_size_m,        // Connects to mem_size
    output reg        sign_ext_m,         // Connects to sign_ext
  output conv_busy_out,
  output conv_done_out
);
  
  //signals from ex_stage to ex_mem_reg
  wire [31:0] branch_target_pc_w;
  wire        branch_taken_w;    

    // 5. Outputs to EX/MEM Pipeline Register (Late Mux Style)
  wire [31:0] alu_result_w;   // Separated for Late Mux
  wire [31:0] conv_result_w;  // Separated for Late Mux
  wire [31:0] out_pc_plus_4_w;    // Separated for Late Mux
  wire [31:0] ex_store_data_w;   
  wire [4:0]  ex_mem_rd_addr_w;
    
    // 7. Pipeline Stall Logic
    wire        conv_busy_w,done_w;       
  wire [1:0]  conv_status_w;
  
  
  //ex_stage instance
  
  
   ex_stage ex_stage_inst(
     
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
     
     //outputs
    // 4. Outputs to IF Stage (PC Logic)
    .branch_target_pc(branch_target_pc_w),
    .branch_taken(branch_taken_w),    

    // 5. Outputs to EX/MEM Pipeline Register (Late Mux Style)
    .alu_result(alu_result_w),   // Separated for Late Mux
    .conv_result(conv_result_w),  // Separated for Late Mux
    .out_pc_plus_4(out_pc_plus_4_w),    // Separated for Late Mux
    .ex_store_data(ex_store_data_w),   
    .ex_mem_rd_addr(ex_mem_rd_addr_w),
    
    // 7. Pipeline Stall Logic
     .conv_busy(conv_busy_w),
     .done(done_w),       
    .conv_status(conv_status_w)      
);

  
  //ex_mem_reg instance
  
  
   ex_mem_reg ex_mem_reg_inst(
     
     //inputs
     
     .clk(clk),
     .rst_n(rst_n),
     .conv_busy(conv_busy_w),      
     .branch_taken(branch_taken_w),       

     .alu_result_e(alu_result_w),
     .conv_result_e(conv_result_w),
     .out_pc_plus_4_e(out_pc_plus_4_w),
     .ex_store_data_e(ex_store_data_w),
     .ex_mem_rd_addr_e(ex_mem_rd_addr_w),
     .conv_done_in(done_w),

     .mem_read_e(mem_read_e),
     .mem_write_e(mem_write_e),
     .reg_write_e(reg_write_e),
     .wb_sel_e(wb_sel_e),
     .mem_size_e(mem_size_e),
     .sign_ext_e(sign_ext_e),
     
     //outputs
     .conv_done_out(conv_done_out),

     .alu_result_m(alu_result_m),      // Connects to alu_result_in
     .conv_result_m(conv_result_m),     // Connects to conv_PE_result_in
     .out_pc_plus_4_m(out_pc_plus_4_m),   // Usually passed to wb_sel mux
     .rs2_data_m(rs2_data_m),        // Connects to rs2_data (store data)
     .rd_addr_m(rd_addr_m),         // Connects to rd_addr_in
    
     .mem_read_m(mem_read_m),        // Connects to mem_read
     .mem_write_m(mem_write_m),       // Connects to mem_write
     .reg_write_m(reg_write_m),       // Connects to reg_write_in
     .wb_sel_m(wb_sel_m),          // Connects to wb_sel_in
     .mem_size_m(mem_size_m),        // Connects to mem_size
     .sign_ext_m(sign_ext_m),         // Connects to sign_ext
     .conv_busy_out(conv_busy_out)
);
  
  
endmodule