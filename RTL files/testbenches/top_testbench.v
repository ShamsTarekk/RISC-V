`timescale 1ns / 1ps

module tb_riscv_top;

  // DUT inputs
  reg clk;
  reg rst_n;

  reg stall_i;
  reg flush_i;
  reg redirect_valid_i;
  reg [31:0] redirect_pc_i;

  reg [3:0] alu_op;
  reg alu_src_b_sel;

  reg conv_start;
  reg conv_init;

  // DUT outputs
  wire [31:0] id_pc_o;
  wire [31:0] id_pc4_o;
  wire [31:0] id_instr_o;

  wire [31:0] ex_pc_o;
  wire [31:0] ex_pc4_o;

  wire [31:0] ex_rs1_data_o;
  wire [31:0] ex_rs2_data_o;
  wire [31:0] ex_imm_o;

  wire [4:0] ex_rs1_addr_o;
  wire [4:0] ex_rs2_addr_o;
  wire [4:0] ex_rd_addr_o;

  wire ex_mem_read_o;
  wire ex_mem_write_o;

  wire [1:0] ex_mem_size_o;
  wire ex_mem_sign_ext_o;

  wire [1:0] ex_wb_sel_o;
  wire [3:0] ex_alu_op_o;
  wire ex_alu_src_imm_o;

  wire ex_jump_o;
  wire ex_jalr_o;

  wire ex_is_conv_o;
  wire ex_conv_init_o;

  wire [31:0] wb_data;
  wire reg_write;
  wire [4:0] rd_addr;

  wire conv_done;
  wire conv_busy_o;

  wire [2:0] branch_type;

  // DUT
  riscv_top dut (
    .clk(clk),
    .rst_n(rst_n),

    .stall_i(stall_i),
    .flush_i(flush_i),
    .redirect_valid_i(redirect_valid_i),
    .redirect_pc_i(redirect_pc_i),

    .alu_op(alu_op),
    .alu_src_b_sel(alu_src_b_sel),

    .conv_start(conv_start),
    .conv_init(conv_init),

    .id_pc_o(id_pc_o),
    .id_pc4_o(id_pc4_o),
    .id_instr_o(id_instr_o),

    .ex_pc_o(ex_pc_o),
    .ex_pc4_o(ex_pc4_o),

    .ex_rs1_data_o(ex_rs1_data_o),
    .ex_rs2_data_o(ex_rs2_data_o),
    .ex_imm_o(ex_imm_o),

    .ex_rs1_addr_o(ex_rs1_addr_o),
    .ex_rs2_addr_o(ex_rs2_addr_o),
    .ex_rd_addr_o(ex_rd_addr_o),

    .ex_mem_read_o(ex_mem_read_o),
    .ex_mem_write_o(ex_mem_write_o),

    .ex_mem_size_o(ex_mem_size_o),
    .ex_mem_sign_ext_o(ex_mem_sign_ext_o),

    .ex_wb_sel_o(ex_wb_sel_o),
    .ex_alu_op_o(ex_alu_op_o),
    .ex_alu_src_imm_o(ex_alu_src_imm_o),

    .ex_jump_o(ex_jump_o),
    .ex_jalr_o(ex_jalr_o),

    .ex_is_conv_o(ex_is_conv_o),
    .ex_conv_init_o(ex_conv_init_o),

    .wb_data(wb_data),
    .reg_write(reg_write),
    .rd_addr(rd_addr),

    .conv_done(conv_done),
    .conv_busy_o(conv_busy_o),

    .branch_type(branch_type)
  );

  // Clock
  always #5 clk = ~clk;

  // Dump waveform
  initial begin
    $dumpfile("riscv_tb.vcd");
    $dumpvars(0, tb_riscv_top);
  end

  // =========================
  // TASKS
  // =========================

  task reset;
  begin
    rst_n = 0;
    stall_i = 0;
    flush_i = 0;
    redirect_valid_i = 0;
    redirect_pc_i = 0;
    alu_op = 0;
    alu_src_b_sel = 0;
    conv_start = 0;
    conv_init = 0;

    repeat(3) @(posedge clk);
    rst_n = 1;
    @(posedge clk);
  end
  endtask

  task run_cycles(input integer n);
  integer i;
  begin
    for (i = 0; i < n; i = i + 1)
      @(posedge clk);
  end
  endtask

  // =========================
  // TEST SEQUENCE
  // =========================

  initial begin
    clk = 0;
    reset();

    $display("\n===== TEST 1: ALU ADD =====");
    alu_op = 4'b0000;
    alu_src_b_sel = 0;
    run_cycles(5);

    $display("\n===== TEST 2: ALU SUB =====");
    alu_op = 4'b0001;
    alu_src_b_sel = 0;
    run_cycles(5);

    $display("\n===== TEST 3: ALU IMM MODE =====");
    alu_op = 4'b0010;
    alu_src_b_sel = 1;
    run_cycles(5);

    $display("\n===== TEST 4: LOAD/STORE PATH ACTIVITY =====");
    // These depend on ID decoding → just observe control propagation
    alu_op = 4'b0000;
    run_cycles(10);

    $display("\n===== TEST 5: CONV START =====");
    conv_init = 1;
    @(posedge clk);
    conv_init = 0;

    conv_start = 1;
    @(posedge clk);
    conv_start = 0;

    run_cycles(20);

    $display("\n===== TEST 6: STALL PIPELINE =====");
    stall_i = 1;
    run_cycles(5);
    stall_i = 0;

    $display("\n===== TEST 7: FLUSH PIPELINE =====");
    flush_i = 1;
    @(posedge clk);
    flush_i = 0;
    run_cycles(5);

    $display("\n===== TEST 8: BRANCH REDIRECT =====");
    redirect_pc_i = 32'h100;
    redirect_valid_i = 1;
    @(posedge clk);
    redirect_valid_i = 0;

    run_cycles(10);

    $display("\n===== TEST COMPLETE =====");
    $finish;
  end

  // =========================
  // MONITOR
  // =========================

  initial begin
    $monitor(
      "T=%0t | PC=%h | INSTR=%h | ALU_OP=%b | RS1=%h RS2=%h | WB=%h | REGW=%b | CONV(b/d)=%b/%b | BR=%b",
      $time,
      id_pc_o,
      id_instr_o,
      alu_op,
      ex_rs1_data_o,
      ex_rs2_data_o,
      wb_data,
      reg_write,
      conv_busy_o,
      conv_done,
      branch_type
    );
  end


  initial begin
    $dumpfile("waveform.vcd");
    
    $dumpvars();
  end
  
  
endmodule
`default_nettype wire
