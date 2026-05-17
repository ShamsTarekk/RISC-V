class riscv_sequence_item extends uvm_sequence_item;

  `uvm_object_utils_begin(riscv_sequence_item)


    `uvm_field_int(rst_n,              UVM_ALL_ON)
    `uvm_field_int(stall_i,            UVM_ALL_ON)
    `uvm_field_int(flush_i,            UVM_ALL_ON)

    `uvm_field_int(redirect_valid_i,   UVM_ALL_ON)
    `uvm_field_int(redirect_pc_i,      UVM_ALL_ON)

    `uvm_field_int(alu_op,             UVM_ALL_ON)
    `uvm_field_int(alu_src_b_sel,      UVM_ALL_ON)

    `uvm_field_int(conv_start,         UVM_ALL_ON)
    `uvm_field_int(conv_init,          UVM_ALL_ON)

    `uvm_field_int(instr,              UVM_ALL_ON)

    `uvm_field_int(rs1_addr,           UVM_ALL_ON)
    `uvm_field_int(rs2_addr,           UVM_ALL_ON)

    `uvm_field_int(id_pc_o,            UVM_ALL_ON)
    `uvm_field_int(id_pc4_o,           UVM_ALL_ON)
    `uvm_field_int(id_instr_o,         UVM_ALL_ON)

    `uvm_field_int(ex_pc_o,            UVM_ALL_ON)
    `uvm_field_int(ex_pc4_o,           UVM_ALL_ON)

    `uvm_field_int(ex_rs1_data_o,      UVM_ALL_ON)
    `uvm_field_int(ex_rs2_data_o,      UVM_ALL_ON)
    `uvm_field_int(ex_imm_o,           UVM_ALL_ON)

    `uvm_field_int(ex_rs1_addr_o,      UVM_ALL_ON)
    `uvm_field_int(ex_rs2_addr_o,      UVM_ALL_ON)
    `uvm_field_int(ex_rd_addr_o,       UVM_ALL_ON)

    `uvm_field_int(ex_mem_read_o,      UVM_ALL_ON)
    `uvm_field_int(ex_mem_write_o,     UVM_ALL_ON)
    `uvm_field_int(ex_mem_size_o,      UVM_ALL_ON)
    `uvm_field_int(ex_mem_sign_ext_o,  UVM_ALL_ON)

    `uvm_field_int(ex_wb_sel_o,        UVM_ALL_ON)

    `uvm_field_int(ex_alu_op_o,        UVM_ALL_ON)
    `uvm_field_int(ex_alu_src_imm_o,   UVM_ALL_ON)

    `uvm_field_int(ex_jump_o,          UVM_ALL_ON)
    `uvm_field_int(ex_jalr_o,          UVM_ALL_ON)

    `uvm_field_int(ex_is_conv_o,       UVM_ALL_ON)
    `uvm_field_int(ex_conv_init_o,     UVM_ALL_ON)

    `uvm_field_int(wb_data,            UVM_ALL_ON)
    `uvm_field_int(reg_write,          UVM_ALL_ON)
    `uvm_field_int(rd_addr,            UVM_ALL_ON)

    `uvm_field_int(conv_done,          UVM_ALL_ON)
    `uvm_field_int(conv_busy_o,        UVM_ALL_ON)

    `uvm_field_int(branch_type,        UVM_ALL_ON)

  `uvm_object_utils_end

  rand logic        rst_n;

  rand logic        stall_i;
  rand logic        flush_i;

  rand logic        redirect_valid_i;
  rand logic [31:0] redirect_pc_i;

  rand logic [3:0]  alu_op;
  rand logic        alu_src_b_sel;

  rand logic        conv_start;
  rand logic        conv_init;

  rand logic [31:0] instr;

  rand logic [4:0]  rs1_addr;
  rand logic [4:0]  rs2_addr;

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
  logic [4:0]  rd_addr;   // mirrors ex_rd_addr_o, set by monitor

  logic        conv_done;
  logic        conv_busy_o;

  logic [2:0]  branch_type;

  constraint riscv_stim_c {


    rst_n dist {
      1'b1 := 95,
      1'b0 := 5
    };

    if (!rst_n) {
      stall_i          == 0;
      flush_i          == 0;
      redirect_valid_i == 0;
      conv_start       == 0;
      conv_init        == 0;
    }

 

    alu_op inside {[0:7]};


    stall_i dist { 0 := 80, 1 := 20 };
    flush_i dist { 0 := 90, 1 := 10 };

    redirect_valid_i dist { 0 := 90, 1 := 10 };

    if (redirect_valid_i) {
      redirect_pc_i[1:0] == 2'b00;
    }


    conv_init  dist { 0 := 95, 1 := 5  };
    conv_start dist { 0 := 90, 1 := 10 };

    // conv_start requires conv_init
    conv_start -> conv_init;


    rs1_addr inside {[1:31]};
    rs2_addr inside {[1:31]};

  }

  function new(string name = "riscv_sequence_item");
    super.new(name);
  endfunction

endclass