`timescale 1ns/1ps

module mem_top_tb;

  //==========================================================
  // Inputs
  //==========================================================
  reg clk;
  reg rst_n;

  reg mem_read;
  reg mem_write;

  reg [31:0] alu_result_in;
  reg [31:0] rs2_data;

  reg reg_write_in;
  reg [1:0] wb_sel_in;
  reg [4:0] rd_addr_in;

  reg [31:0] conv_PE_result_in;
  reg [31:0] out_pc_plus_4_in;

  reg [1:0] mem_size;
  reg sign_ext;

  reg conv_busy;

  //==========================================================
  // Outputs
  //==========================================================
  wire [31:0] wb_data;
  wire reg_write;
  wire [4:0] rd_addr;

  //==========================================================
  // DUT
  //==========================================================
  mem_top DUT (
    .clk(clk),
    .rst_n(rst_n),

    .mem_read(mem_read),
    .mem_write(mem_write),

    .alu_result_in(alu_result_in),
    .rs2_data(rs2_data),

    .reg_write_in(reg_write_in),
    .wb_sel_in(wb_sel_in),
    .rd_addr_in(rd_addr_in),

    .conv_PE_result_in(conv_PE_result_in),
    .out_pc_plus_4_in(out_pc_plus_4_in),

    .mem_size(mem_size),
    .sign_ext(sign_ext),

    .conv_busy(conv_busy),

    .wb_data(wb_data),
    .reg_write(reg_write),
    .rd_addr(rd_addr)
  );

  //==========================================================
  // Clock Generation
  //==========================================================
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  //==========================================================
  // Test Sequence
  //==========================================================
  initial begin

    //======================================================
    // Initialize
    //======================================================
    rst_n               = 0;

    mem_read            = 0;
    mem_write           = 0;

    alu_result_in       = 0;
    rs2_data            = 0;

    reg_write_in        = 0;
    wb_sel_in           = 0;
    rd_addr_in          = 0;

    conv_PE_result_in   = 0;
    out_pc_plus_4_in    = 0;

    mem_size            = 2'b10;
    sign_ext            = 0;

    conv_busy           = 0;

    // Reset
    #20;
    rst_n = 1;

    //======================================================
    // TEST 1 : ALU RESULT WRITEBACK
    // wb_sel = 00
    //======================================================
    @(posedge clk);

    mem_read          = 0;
    mem_write         = 0;

    alu_result_in     = 32'h00001234;
    reg_write_in      = 1;

    wb_sel_in         = 2'b00;
    rd_addr_in        = 5'd5;

    conv_PE_result_in = 32'hAAAAAAAA;
    out_pc_plus_4_in  = 32'h00000004;

    $display("\n==============================");
    $display("TEST 1 : ALU WRITEBACK");
    $display("==============================");

    @(posedge clk);
    #1;

    $display("WB DATA    = %h", wb_data);
    $display("RD ADDR    = %d", rd_addr);
    $display("REG WRITE  = %b", reg_write);

    //======================================================
    // TEST 2 : LOAD STORE
    //======================================================

    // STORE WORD
    @(posedge clk);

    mem_write         = 1;
    mem_read          = 0;

    alu_result_in     = 32'h00000010;
    rs2_data          = 32'hDEADBEEF;

    mem_size          = 2'b10;

    $display("\n==============================");
    $display("TEST 2 : STORE WORD");
    $display("==============================");

    @(posedge clk);

    // LOAD WORD
    mem_write         = 0;
    mem_read          = 1;

    wb_sel_in         = 2'b01;
    rd_addr_in        = 5'd10;

    @(posedge clk);
    #1;

    $display("LOADED WB DATA = %h", wb_data);

    //======================================================
    // TEST 3 : CONV RESULT WRITEBACK
    // wb_sel = 10
    //======================================================
    @(posedge clk);

    mem_read            = 0;
    mem_write           = 0;

    conv_PE_result_in   = 32'hCAFEBABE;

    wb_sel_in           = 2'b10;
    reg_write_in        = 1;
    rd_addr_in          = 5'd15;

    $display("\n==============================");
    $display("TEST 3 : CONV WRITEBACK");
    $display("==============================");

    @(posedge clk);
    #1;

    $display("WB DATA = %h", wb_data);

    //======================================================
    // TEST 4 : PC+4 WRITEBACK
    // wb_sel = 11
    //======================================================
    @(posedge clk);

    out_pc_plus_4_in  = 32'h00000100;

    wb_sel_in         = 2'b11;
    rd_addr_in        = 5'd1;

    $display("\n==============================");
    $display("TEST 4 : PC+4 WRITEBACK");
    $display("==============================");

    @(posedge clk);
    #1;

    $display("WB DATA = %h", wb_data);

    //======================================================
    // TEST 5 : conv_busy stall behavior
    //======================================================
    @(posedge clk);

    conv_busy         = 1;

    alu_result_in     = 32'h11111111;
    wb_sel_in         = 2'b00;

    $display("\n==============================");
    $display("TEST 5 : CONV BUSY");
    $display("==============================");

    @(posedge clk);
    #1;

    $display("WB DATA DURING BUSY = %h", wb_data);

    conv_busy = 0;

    //======================================================
    // Finish
    //======================================================
    #50;

    $display("\nALL TESTS COMPLETED\n");

    $finish;
  end

  //==========================================================
  // Monitor
  //==========================================================
  initial begin
    $monitor("TIME=%0t | wb_data=%h | reg_write=%b | rd_addr=%d",
              $time, wb_data, reg_write, rd_addr);
  end


  initial begin
    $dumpfile("waveform.vcd");
    
    $dumpvars();
  end
  
  
endmodule
`default_nettype wire