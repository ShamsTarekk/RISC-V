

interface riscv_interface (input logic clk);


  logic        rst_n;

  logic        stall_i;
  logic        flush_i;

  logic        redirect_valid_i;
  logic [31:0] redirect_pc_i;

  logic [3:0]  alu_op;
  logic        alu_src_b_sel;

  logic        conv_start;
  logic        conv_init;

  logic [31:0] id_pc_o;
  logic [31:0] id_pc4_o;
  logic [31:0] id_instr_o;

  logic [31:0] ex_pc_o;
  logic [31:0] ex_pc4_o;

  logic [31:0] ex_rs1_data_o;
  logic [31:0] ex_rs2_data_o;
  logic [31:0] ex_imm_o;

  logic [4:0]  ex_rs1_addr_o;
  logic [4:0]  ex_rs2_addr_o;
  logic [4:0]  ex_rd_addr_o;

  logic        ex_mem_read_o;
  logic        ex_mem_write_o;
  logic [1:0]  ex_mem_size_o;
  logic        ex_mem_sign_ext_o;

  logic [1:0]  ex_wb_sel_o;
  logic [3:0]  ex_alu_op_o;
  logic        ex_alu_src_imm_o;

  logic        ex_jump_o;
  logic        ex_jalr_o;

  logic        ex_is_conv_o;
  logic        ex_conv_init_o;

  logic [31:0] wb_data;
  logic        reg_write;
  logic [4:0]  rd_addr;

  logic        conv_done;
  logic        conv_busy_o;

  logic [2:0]  branch_type;

  clocking drv_cb @(posedge clk);
    default input  #1
            output #1;

    output rst_n;
    output stall_i;
    output flush_i;
    output redirect_valid_i;
    output redirect_pc_i;
    output alu_op;
    output alu_src_b_sel;
    output conv_start;
    output conv_init;
  endclocking


  clocking mon_cb @(posedge clk);
    default input #1;

    input rst_n;
    input stall_i;
    input flush_i;
    input redirect_valid_i;
    input redirect_pc_i;
    input alu_op;
    input alu_src_b_sel;
    input conv_start;
    input conv_init;

    input id_pc_o;
    input id_pc4_o;
    input id_instr_o;
    input ex_pc_o;
    input ex_pc4_o;
    input ex_rs1_data_o;
    input ex_rs2_data_o;
    input ex_imm_o;
    input ex_rs1_addr_o;
    input ex_rs2_addr_o;
    input ex_rd_addr_o;
    input ex_mem_read_o;
    input ex_mem_write_o;
    input ex_mem_size_o;
    input ex_mem_sign_ext_o;
    input ex_wb_sel_o;
    input ex_alu_op_o;
    input ex_alu_src_imm_o;
    input ex_jump_o;
    input ex_jalr_o;
    input ex_is_conv_o;
    input ex_conv_init_o;
    input wb_data;
    input reg_write;
    input rd_addr;
    input conv_done;
    input conv_busy_o;
    input branch_type;
  endclocking

endinterface