class riscv_monitor extends uvm_monitor;

  `uvm_component_utils(riscv_monitor)


  virtual riscv_interface vif;

  uvm_analysis_port #(riscv_sequence_item) monitor_port;

  riscv_sequence_item item;

  function new(string name = "riscv_monitor", uvm_component parent);
    super.new(name, parent);
    `uvm_info("MONITOR", "Constructor", UVM_HIGH)
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("MONITOR", "Build Phase", UVM_HIGH)

    monitor_port = new("monitor_port", this);

    if (!uvm_config_db #(virtual riscv_interface)::get(
          this, "", "vif", vif))
      `uvm_fatal("MONITOR",
        "Failed to get virtual interface from config DB")
  endfunction

  task run_phase(uvm_phase phase);
    `uvm_info("MONITOR", "Run Phase Started", UVM_HIGH)


    @(posedge vif.clk);
    wait(vif.rst_n === 1'b1);

    forever begin

      @(vif.mon_cb);

      if (!vif.mon_cb.rst_n)
        continue;

      item = riscv_sequence_item::type_id::create("item");


      item.rst_n            = vif.mon_cb.rst_n;
      item.stall_i          = vif.mon_cb.stall_i;
      item.flush_i          = vif.mon_cb.flush_i;
      item.redirect_valid_i = vif.mon_cb.redirect_valid_i;
      item.redirect_pc_i    = vif.mon_cb.redirect_pc_i;
      item.alu_op           = vif.mon_cb.alu_op;
      item.alu_src_b_sel    = vif.mon_cb.alu_src_b_sel;
      item.conv_start       = vif.mon_cb.conv_start;
      item.conv_init        = vif.mon_cb.conv_init;


      item.id_pc_o           = vif.mon_cb.id_pc_o;
      item.id_pc4_o          = vif.mon_cb.id_pc4_o;
      item.id_instr_o        = vif.mon_cb.id_instr_o;

      item.ex_pc_o           = vif.mon_cb.ex_pc_o;
      item.ex_pc4_o          = vif.mon_cb.ex_pc4_o;

      item.ex_rs1_data_o     = vif.mon_cb.ex_rs1_data_o;
      item.ex_rs2_data_o     = vif.mon_cb.ex_rs2_data_o;
      item.ex_imm_o          = vif.mon_cb.ex_imm_o;

      item.ex_rs1_addr_o     = vif.mon_cb.ex_rs1_addr_o;
      item.ex_rs2_addr_o     = vif.mon_cb.ex_rs2_addr_o;
      item.ex_rd_addr_o      = vif.mon_cb.ex_rd_addr_o;

      item.ex_mem_read_o     = vif.mon_cb.ex_mem_read_o;
      item.ex_mem_write_o    = vif.mon_cb.ex_mem_write_o;
      item.ex_mem_size_o     = vif.mon_cb.ex_mem_size_o;
      item.ex_mem_sign_ext_o = vif.mon_cb.ex_mem_sign_ext_o;

      item.ex_wb_sel_o       = vif.mon_cb.ex_wb_sel_o;
      item.ex_alu_op_o       = vif.mon_cb.ex_alu_op_o;
      item.ex_alu_src_imm_o  = vif.mon_cb.ex_alu_src_imm_o;

      item.ex_jump_o         = vif.mon_cb.ex_jump_o;
      item.ex_jalr_o         = vif.mon_cb.ex_jalr_o;

      item.ex_is_conv_o      = vif.mon_cb.ex_is_conv_o;
      item.ex_conv_init_o    = vif.mon_cb.ex_conv_init_o;

      item.wb_data           = vif.mon_cb.wb_data;
      item.reg_write         = vif.mon_cb.reg_write;

      item.rd_addr           = vif.mon_cb.rd_addr;
      item.ex_rd_addr_o      = vif.mon_cb.ex_rd_addr_o;

      item.conv_done         = vif.mon_cb.conv_done;
      item.conv_busy_o       = vif.mon_cb.conv_busy_o;

      item.branch_type       = vif.mon_cb.branch_type;


      monitor_port.write(item);


      `uvm_info(
        "MONITOR",
        $sformatf(
          "T=%0t | PC=%08h | INSTR=%08h | ALU_OP=%0d | RS1=%08h | RS2=%08h | WB=%08h | RD=x%0d | REGW=%0b | CONV_BUSY=%0b | CONV_DONE=%0b | BRANCH=%0d",
          $time,
          item.id_pc_o,
          item.id_instr_o,
          item.ex_alu_op_o,
          item.ex_rs1_data_o,
          item.ex_rs2_data_o,
          item.wb_data,
          item.rd_addr,
          item.reg_write,
          item.conv_busy_o,
          item.conv_done,
          item.branch_type
        ),
        UVM_MEDIUM
      );

    end

  endtask

endclass
    
    
class conv_pe_monitor extends uvm_monitor;

  `uvm_component_utils(conv_pe_monitor)

  virtual riscv_interface vif;

  uvm_analysis_port #(riscv_sequence_item)
    monitor_port;

  riscv_sequence_item item;

  function new(string name,
               uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    monitor_port = new("monitor_port", this);

    if(!uvm_config_db #(virtual riscv_interface)::get(
          this, "", "vif", vif))
      `uvm_fatal("CONV_MON",
                 "Virtual interface not found")
  endfunction

  task run_phase(uvm_phase phase);

    forever begin

      @(vif.mon_cb);

      if(!vif.mon_cb.rst_n)
        continue;

      item = riscv_sequence_item::type_id::create(
               "conv_item");

      item.conv_init   = vif.mon_cb.conv_init;
      item.conv_start  = vif.mon_cb.conv_start;
      item.conv_done   = vif.mon_cb.conv_done;
      item.conv_busy_o = vif.mon_cb.conv_busy_o;

      if (^item.id_pc_o !== 1'bx &&
          ^item.id_instr_o !== 1'bx &&
          ^item.ex_alu_op_o !== 1'bx) begin

        monitor_port.write(item);

      end
    end

  endtask

endclass
