`include "if_stage.v"
`include "if_id_reg.v"

//integration of if_stage and if_id_reg


module if_stage_id_reg (
    input  wire        clk,
    input  wire        rst_n,

    // Global pipeline controls
    input  wire        stall_i,// freeze PC while Conv-PE is busy
  	input wire 		   flush_i,
    input  wire        redirect_valid_i, // branch/JAL/JALR taken in EX
    input  wire [31:0] redirect_pc_i,
    output reg  [31:0] id_pc_o,
    output reg  [31:0] id_pc4_o,
    output reg  [31:0] id_instr_o

);
  
  //signals between if_stage and if_id_reg 
  
      // Output toward IF/ID pipeline register
  wire [31:0] if_pc_o_w;
  wire [31:0] if_pc4_o_w;
  wire [31:0] if_instr_o_w;

  
  
   if_stage if_stage_inst(
    
    //inputs
    .clk(clk),
    .rst_n(rst_n),

    // Global pipeline controls
    .stall_i(stall_i),          // freeze PC while Conv-PE is busy
    .redirect_valid_i(redirect_valid_i), // branch/JAL/JALR taken in EX
    .redirect_pc_i(redirect_pc_i),
    
    //outputs

    // Output toward IF/ID pipeline register
    .if_pc_o(if_pc_o_w),
    .if_pc4_o(if_pc4_o_w),
    .if_instr_o(if_instr_o_w)
);
  
   if_id_reg if_id_reg_inst(
     .clk(clk),
     .rst_n(rst_n),
     .stall_i(stall_i),
     .flush_i(flush_i),

     .if_pc_i(if_pc_o_w),
     .if_pc4_i(if_pc4_o_w),
     .if_instr_i(if_instr_o_w),

     .id_pc_o(id_pc_o),
     .id_pc4_o(id_pc4_o),
     .id_instr_o(id_instr_o)
);
    
    
endmodule