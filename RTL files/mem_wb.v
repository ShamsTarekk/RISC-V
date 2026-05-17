module mem_wb(input clk, rst_n,
  			  input [31:0] mem_data,
              input [1:0] wb_sel_in,
              input [31:0] alu_result_in,
              input [31:0] conv_PE_result_in,
              input [31:0] out_pc_plus_4_in,
              input [4:0] rd_addr_in,
              input reg_write_in,
              input conv_busy,
              output reg [31:0] alu_result,
              output reg [31:0] load_data,
              output reg [31:0] conv_PE_result,
              output reg [1:0] wb_sel,
              output reg [4:0] rd_addr,
              output reg [31:0] out_pc_plus_4_out,
             output reg reg_write);
  
  
  always @(posedge clk ) begin
    if (!rst_n) begin
      alu_result <= 0;
      load_data <= 0;
      conv_PE_result <= 0;
      wb_sel <= 0;
      rd_addr <= 0;
      reg_write <= 0;
      out_pc_plus_4_out <= 0;
    end
    else 
      begin
        wb_sel <= wb_sel_in;
        alu_result <= alu_result_in;
        load_data <= mem_data;
        
        reg_write <= reg_write_in;
        out_pc_plus_4_out <= out_pc_plus_4_in;
        if(reg_write_in) begin
          rd_addr <= rd_addr_in;
        end
        else begin
          rd_addr <= 0;
        end
        if (!conv_busy) begin
          conv_PE_result <= conv_PE_result_in;
        end
        else
          conv_PE_result <= conv_PE_result;
      end
      
  end
endmodule