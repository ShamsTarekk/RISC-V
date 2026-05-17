// Code your design here

`include "dmem.v"
module mem_stage (input clk, 
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
                  output [31:0] mem_data,
                  output [1:0] wb_sel_out,
                  output [31:0] alu_result_out,
                  output [31:0] conv_PE_result_out,
                  output [4:0] rd_addr_out,
                  output [31:0] out_pc_plus_4_out,
                 output reg_write_out);
  
  wire [31:0] rdata_reg;
  
  dmem X0 (.clk(clk),
          .we(mem_write),
          .wsize(mem_size),
          .waddr(alu_result_in),
          .wdata(rs2_data),
          .raddr(alu_result_in),
          .rsize(mem_size),
          .sign_ext(sign_ext),
          .rdata(rdata_reg));

  assign mem_data = rdata_reg;
  assign wb_sel_out = wb_sel_in;
  assign alu_result_out = alu_result_in;
  assign conv_PE_result_out = conv_PE_result_in;
  assign rd_addr_out = rd_addr_in;
  assign reg_write_out = reg_write_in;
  assign out_pc_plus_4_out = out_pc_plus_4_in;
  
endmodule