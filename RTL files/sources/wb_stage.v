module wb_stage (
    input  [31:0] alu_result,
    input  [31:0] load_data,
    input  [31:0] conv_PE_result,
    input  [1:0]  wb_sel,
  	input reg_write,
    input  [31:0] out_pc_plus_4,
    output reg [31:0] wb_data
);
  
  reg [31:0] wb_data_reg;

  always @(*) begin
    case (wb_sel)
      2'b00: wb_data_reg = alu_result;
      2'b01: wb_data_reg = load_data;
      2'b10: wb_data_reg = conv_PE_result;
      2'b11: wb_data_reg = out_pc_plus_4;
      default: wb_data_reg = 32'h0;
    endcase
  end
  
  always @(*) begin
    if(reg_write) begin
      wb_data = wb_data_reg;
    end
    else
      wb_data = 0;
  end

endmodule