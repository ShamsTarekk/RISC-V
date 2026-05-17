
`timescale 1ns/1ns
import uvm_pkg::*;
`include "uvm_macros.svh"

`include "interface.sv"
`include "sequence_item.sv"
`include "sequencer.sv"
`include "sequence.sv"
`include "monitor.sv"
`include "driver.sv"
`include "agent.sv"
`include "scoreboard.sv"
`include "coverage.sv"
`include "env.sv"
`include "test.sv"

module top();

  logic clk;


  initial begin
    clk = 0;
    forever #10 clk = ~clk;
  end

  riscv_interface intf (.clk(clk));


  riscv_top dut (
    .clk               (intf.clk),
    .rst_n             (intf.rst_n),
    .stall_i           (intf.stall_i),
    .flush_i           (intf.flush_i),
    .redirect_valid_i  (intf.redirect_valid_i),
    .redirect_pc_i     (intf.redirect_pc_i),
    .alu_op            (intf.alu_op),
    .alu_src_b_sel     (intf.alu_src_b_sel),
    .conv_start        (intf.conv_start),
    .conv_init         (intf.conv_init),
    .id_pc_o           (intf.id_pc_o),
    .id_pc4_o          (intf.id_pc4_o),
    .id_instr_o        (intf.id_instr_o),
    .ex_pc_o           (intf.ex_pc_o),
    .ex_pc4_o          (intf.ex_pc4_o),
    .ex_rs1_data_o     (intf.ex_rs1_data_o),
    .ex_rs2_data_o     (intf.ex_rs2_data_o),
    .ex_imm_o          (intf.ex_imm_o),
    .ex_rs1_addr_o     (intf.ex_rs1_addr_o),
    .ex_rs2_addr_o     (intf.ex_rs2_addr_o),
    .ex_rd_addr_o      (intf.ex_rd_addr_o),
    .ex_mem_read_o     (intf.ex_mem_read_o),
    .ex_mem_write_o    (intf.ex_mem_write_o),
    .ex_mem_size_o     (intf.ex_mem_size_o),
    .ex_mem_sign_ext_o (intf.ex_mem_sign_ext_o),
    .ex_wb_sel_o       (intf.ex_wb_sel_o),
    .ex_alu_op_o       (intf.ex_alu_op_o),
    .ex_alu_src_imm_o  (intf.ex_alu_src_imm_o),
    .ex_jump_o         (intf.ex_jump_o),
    .ex_jalr_o         (intf.ex_jalr_o),
    .ex_is_conv_o      (intf.ex_is_conv_o),
    .ex_conv_init_o    (intf.ex_conv_init_o),
    .wb_data           (intf.wb_data),
    .reg_write         (intf.reg_write),
    .rd_addr           (intf.rd_addr),
    .conv_done         (intf.conv_done),
    .conv_busy_o       (intf.conv_busy_o),
    .branch_type       (intf.branch_type)
  );



  initial begin
    uvm_config_db #(virtual riscv_interface)::set(
      null, "*", "vif", intf);
  end


  initial begin
    run_test("riscv_test");
  end

  initial begin
    #5000;
    `uvm_fatal("TOP", "Simulation watchdog timeout — check objections")
    $finish();
  end

  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars();
  end

endmodule