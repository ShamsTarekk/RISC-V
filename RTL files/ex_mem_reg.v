module ex_mem_reg (
    input clk,
    input rst_n,
    input conv_busy,      
    input branch_taken,       

    input [31:0] alu_result_e,
    input [31:0] conv_result_e,
    input [31:0] out_pc_plus_4_e,
    input [31:0] ex_store_data_e,
    input [4:0]  ex_mem_rd_addr_e,
  input conv_done_in,

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
  
  assign conv_busy_out = conv_busy;
  assign conv_done_out = conv_done_in;

    always @(posedge clk) begin
        if (!rst_n) begin
            alu_result_m    <= 0;
            conv_result_m   <= 0;
            out_pc_plus_4_m <= 0;
            rs2_data_m      <= 0;
            rd_addr_m       <= 0;
            mem_read_m      <= 0;
            mem_write_m     <= 0;
            reg_write_m     <= 0;
            wb_sel_m        <= 0;
            mem_size_m      <= 0;
            sign_ext_m      <= 0;
        end 
        else if (branch_taken) begin
          alu_result_m    <= 0;
          conv_result_m   <= 0;
          out_pc_plus_4_m <= 0;
          rs2_data_m      <= 0;
          rd_addr_m       <= 0;

          mem_read_m      <= 0;
          mem_write_m     <= 0;
          reg_write_m     <= 0;

          wb_sel_m        <= 0;
          mem_size_m      <= 0;
          sign_ext_m      <= 0;
        end
        else if (!conv_busy) begin
            alu_result_m    <= alu_result_e;
            conv_result_m   <= conv_result_e;
            out_pc_plus_4_m <= out_pc_plus_4_e;
            rs2_data_m      <= ex_store_data_e;
            rd_addr_m       <= ex_mem_rd_addr_e;
            mem_read_m      <= mem_read_e;
            mem_write_m     <= mem_write_e;
            reg_write_m     <= reg_write_e;
            wb_sel_m        <= wb_sel_e;
            mem_size_m      <= mem_size_e;
            sign_ext_m      <= sign_ext_e;
        end
    end

endmodule