class riscv_driver extends uvm_driver #(riscv_sequence_item);

  `uvm_component_utils(riscv_driver)


  virtual riscv_interface vif;


  riscv_sequence_item item;



  function new(string name = "riscv_driver", uvm_component parent);
    super.new(name, parent);
    `uvm_info("DRIVER", "Constructor", UVM_HIGH)
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("DRIVER", "Build Phase", UVM_HIGH)

    if (!uvm_config_db #(virtual riscv_interface)::get(
          this, "", "vif", vif))
      `uvm_fatal("DRIVER",
        "Failed to get virtual interface from config DB")
  endfunction


  task run_phase(uvm_phase phase);
    `uvm_info("DRIVER", "Run Phase Started", UVM_HIGH)

    initialize_signals();

    forever begin
      seq_item_port.get_next_item(item);
      drive(item);
      seq_item_port.item_done();
    end
  endtask


  task initialize_signals();

    vif.drv_cb.rst_n            <= 0;
    vif.drv_cb.stall_i          <= 0;
    vif.drv_cb.flush_i          <= 0;
    vif.drv_cb.redirect_valid_i <= 0;
    vif.drv_cb.redirect_pc_i    <= 32'h0;
    vif.drv_cb.alu_op           <= 4'h0;
    vif.drv_cb.alu_src_b_sel    <= 0;
    vif.drv_cb.conv_start       <= 0;
    vif.drv_cb.conv_init        <= 0;

    repeat (5) @(vif.drv_cb);

    vif.drv_cb.rst_n <= 1;

    `uvm_info("DRIVER", "Interface signals initialized", UVM_LOW)
  endtask


  task drive(riscv_sequence_item item);

    @(vif.drv_cb);


    if (!item.rst_n) begin

      vif.drv_cb.rst_n            <= 0;
      vif.drv_cb.stall_i          <= 0;
      vif.drv_cb.flush_i          <= 0;
      vif.drv_cb.redirect_valid_i <= 0;
      vif.drv_cb.redirect_pc_i    <= 32'h0;
      vif.drv_cb.alu_op           <= 4'h0;
      vif.drv_cb.alu_src_b_sel    <= 0;
      vif.drv_cb.conv_start       <= 0;
      vif.drv_cb.conv_init        <= 0;

      `uvm_info("DRIVER", "Driving RESET transaction", UVM_MEDIUM)

    end


    else begin

      vif.drv_cb.rst_n            <= 1;
      vif.drv_cb.stall_i          <= item.stall_i;
      vif.drv_cb.flush_i          <= item.flush_i;
      vif.drv_cb.redirect_valid_i <= item.redirect_valid_i;
      vif.drv_cb.redirect_pc_i    <= item.redirect_pc_i;
      vif.drv_cb.alu_op           <= item.alu_op;
      vif.drv_cb.alu_src_b_sel    <= item.alu_src_b_sel;
      vif.drv_cb.conv_start       <= item.conv_start;
      vif.drv_cb.conv_init        <= item.conv_init;

      `uvm_info(
        "DRIVER",
        $sformatf(
          "Driving: ALU_OP=%0d STALL=%0b FLUSH=%0b REDIR=%0b CONV_INIT=%0b CONV_START=%0b INSTR=%08h",
          item.alu_op,
          item.stall_i,
          item.flush_i,
          item.redirect_valid_i,
          item.conv_init,
          item.conv_start,
          item.instr
        ),
        UVM_MEDIUM
      )

    end

  endtask

endclass