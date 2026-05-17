`include "mem_stage.v"
`include "mem_wb.v"
`include "wb_stage.v"

//integration of memory and write back modules


module mem_top (input clk, rst_n,
                  input mem_read, //used to read data from memory
                  input mem_write, //used to write data into memory
                  input [31:0] alu_result_in, //contains result of the arithmetic operation or address to store the data in for Store/Load instructions
                  input [31:0] rs2_data, //data to store
                  input reg_write_in,
                  input [1:0] wb_sel_in,
                  input [4:0] rd_addr_in,
                  input [31:0] conv_PE_result_in,
                  input [31:0] out_pc_plus_4_in,
                  input [1:0] mem_size,
                  input sign_ext,
                input conv_busy,
                output reg [31:0] wb_data,
                output reg reg_write,
                output conv_busy_o,
                output reg [4:0] rd_addr
               );
  
  
  //signals from mem_stage to mem_wb
  
  wire [31:0] mem_data_w1;
  wire [1:0] wb_sel_out_w1;
  wire [31:0] alu_result_out_w1;
  wire [31:0] conv_PE_result_out_w1;
  wire [4:0] rd_addr_out_w1;
  wire [31:0] out_pc_plus_4_out_w1;
  wire reg_write_out_w1;
  
  
  //signals from mem_wb to wb_stage
  wire [31:0] alu_result_w2;
  wire [31:0] load_data_w1;
  wire [31:0] conv_PE_result_w2;
  wire [1:0] wb_sel_w2;
  wire [31:0] out_pc_plus_4_out_w2;
  assign conv_busy_o = conv_busy;
  
  
  //mem_stage instance
  
  mem_stage mem_inst(
    
    //inputs
    			  .clk(clk), 
                  .mem_read(mem_read), //used to read data from memory
                  .mem_write(mem_write), //used to write data into memory
                  .alu_result_in(alu_result_in), //contains result of the arithmetic operation or address to store the data in for Store/Load instructions
                  .rs2_data(rs2_data), //data to store
                  .reg_write_in(reg_write_in),
                  .wb_sel_in(wb_sel_in),
                  .rd_addr_in(rd_addr_in),
                  .conv_PE_result_in(conv_PE_result_in),
                  .out_pc_plus_4_in(out_pc_plus_4_in),
                  .mem_size(mem_size),
                  .sign_ext(sign_ext),
    	//outputs 
                  .mem_data(mem_data_w1),
                  .wb_sel_out(wb_sel_out_w1),
                  .alu_result_out(alu_result_out_w1),
                  .conv_PE_result_out(conv_PE_result_out_w1),
                  .rd_addr_out(rd_addr_out_w1),
                  .out_pc_plus_4_out(out_pc_plus_4_out_w1),
    .reg_write_out(reg_write_out_w1));
  
  
  //mem_wb instance
  
  mem_wb mem_wb_inst(
    
    				  //inputs
    				 .clk(clk), .rst_n(rst_n),
                     .mem_data(mem_data_w1),
                     .wb_sel_in(wb_sel_out_w1),
                     .alu_result_in(alu_result_out_w1),
                     .conv_PE_result_in(conv_PE_result_out_w1),
                     .out_pc_plus_4_in(out_pc_plus_4_out_w1),
                     .rd_addr_in(rd_addr_out_w1),
                     .reg_write_in(reg_write_out_w1),
                     .conv_busy(conv_busy),
                     //outputs
                     .alu_result(alu_result_w2),
                     .load_data(load_data_w1),
                     .conv_PE_result(conv_PE_result_w2),
                     .wb_sel(wb_sel_w2),
                     .rd_addr(rd_addr),
                     .out_pc_plus_4_out(out_pc_plus_4_out_w2),
                     .reg_write(reg_write));
  
  
  //wb_stage instance
  
   wb_stage wb_stage_inst(
     
     //inputs
     .alu_result(alu_result_w2),
     .load_data(load_data_w1),
     .conv_PE_result(conv_PE_result_w2),
     .wb_sel(wb_sel_w2),
     .reg_write(reg_write),
     .out_pc_plus_4(out_pc_plus_4_out_w2),
     
     //outputs
     .wb_data(wb_data));
  
endmodule
