`timescale 1ns / 1ps

module tb_ex_mem_stages_top;

//====================================================
// DUT Inputs
//====================================================
reg clk;
reg rst_n;

reg [31:0] ex_pc;
reg [31:0] ex_rs1_data;
reg [31:0] ex_rs2_data;
reg [31:0] ex_imm;
reg [4:0]  id_ex_rd_addr;

reg [3:0]  alu_op;
reg        alu_src_b_sel;
reg        conv_start;
reg        conv_init;
reg [2:0]  branch_type;
reg        is_jump;
reg        is_jalr;

reg        mem_read_e;
reg        mem_write_e;
reg        reg_write_e;
reg [1:0]  wb_sel_e;
reg [1:0]  mem_size_e;
reg        sign_ext_e;
reg conv_done;

//====================================================
// DUT Outputs
//====================================================
wire [31:0] wb_data;
wire        reg_write;
wire [4:0]  rd_addr;

//====================================================
// Instantiate DUT
//====================================================
ex_mem_stages_top dut (
    .clk(clk),
    .rst_n(rst_n),

    .ex_pc(ex_pc),
    .ex_rs1_data(ex_rs1_data),
    .ex_rs2_data(ex_rs2_data),
    .ex_imm(ex_imm),
    .id_ex_rd_addr(id_ex_rd_addr),

    .alu_op(alu_op),
    .alu_src_b_sel(alu_src_b_sel),
    .conv_start(conv_start),
    .conv_init(conv_init),
    .branch_type(branch_type),
    .is_jump(is_jump),
    .is_jalr(is_jalr),

    .mem_read_e(mem_read_e),
    .mem_write_e(mem_write_e),
    .reg_write_e(reg_write_e),
    .wb_sel_e(wb_sel_e),
    .mem_size_e(mem_size_e),
    .sign_ext_e(sign_ext_e),

    .wb_data(wb_data),
    .reg_write(reg_write),
  .rd_addr(rd_addr),
  .conv_done(conv_done)
);

//====================================================
// Clock generation
//====================================================
always #5 clk = ~clk;

//====================================================
// Stimulus
//====================================================
initial begin
    // init
    clk = 0;
    rst_n = 0;

    ex_pc = 0;
    ex_rs1_data = 0;
    ex_rs2_data = 0;
    ex_imm = 0;
    id_ex_rd_addr = 0;

    alu_op = 0;
    alu_src_b_sel = 0;
    conv_start = 0;
    conv_init = 0;
    branch_type = 0;
    is_jump = 0;
    is_jalr = 0;

    mem_read_e = 0;
    mem_write_e = 0;
    reg_write_e = 0;
    wb_sel_e = 0;
    mem_size_e = 0;
    sign_ext_e = 0;

    // reset
    #20;
    rst_n = 1;

    //================================================
    // TEST 1: ALU operation (writeback expected)
    //================================================
    #10;
    ex_rs1_data = 32'd10;
    ex_rs2_data = 32'd20;
    id_ex_rd_addr = 5'd5;

    alu_op = 4'b0000;   // assume ADD
    reg_write_e = 1;
    wb_sel_e = 2'b00;   // ALU path

    #20;

    $display("=== TEST 1: ALU ===");
    $display("wb_data = %h | reg_write = %b | rd = %d", wb_data, reg_write, rd_addr);

    //================================================
    // TEST 2: Memory read path
    //================================================
    #10;
    mem_read_e = 1;
    wb_sel_e = 2'b01;   // MEM path
    id_ex_rd_addr = 5'd7;

    #20;

    $display("=== TEST 2: MEM READ ===");
    $display("wb_data = %h | reg_write = %b | rd = %d", wb_data, reg_write, rd_addr);

    //================================================
    // TEST 3: Conv path
    //================================================
    #10;
    conv_init = 1;
    conv_start = 1;
    wb_sel_e = 2'b10;   // CONV path
    id_ex_rd_addr = 5'd10;

    #20;
  #100;

    $display("=== TEST 3: CONV ===");
    $display("wb_data = %h | reg_write = %b | rd = %d", wb_data, reg_write, rd_addr);

    conv_start = 0;
    conv_init = 0;

    //================================================
    // TEST 4: No writeback
    //================================================
    #10;
    reg_write_e = 0;
    mem_read_e = 0;
    conv_start = 0;
    wb_sel_e = 2'b00;

    #20;

    $display("=== TEST 4: NO WRITEBACK ===");
    $display("wb_data = %h | reg_write = %b | rd = %d", wb_data, reg_write, rd_addr);

    // finish
      #500;
    $finish;
end
//====================================================
// MONITOR (prints every cycle)
//====================================================
initial begin
    $display("\nTIME | pc | rs1 | rs2 | imm | rd_in | wb_data | reg_write | rd_out | wb_sel | mem_rd | mem_wr | conv_start | conv_init | conv_done");
    $display("----------------------------------------------------------------------------------------------------------------");

    $monitor(
      "%4t | %h | %h | %h | %h | %d | %h | %b | %d | %b | %b | %b | %b | %b | %b",
        $time,
        ex_pc,
        ex_rs1_data,
        ex_rs2_data,
        ex_imm,
        id_ex_rd_addr,
        wb_data,
        reg_write,
        rd_addr,
        wb_sel_e,
        mem_read_e,
        mem_write_e,
        conv_start,
        conv_init,
      conv_done
    );

end
  initial begin
    $dumpfile("waveform.vcd");
    
    $dumpvars();
  end
  
  
endmodule
`default_nettype wire