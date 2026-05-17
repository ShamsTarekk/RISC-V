class instr_mem_agent extends uvm_agent;

  `uvm_component_utils(instr_mem_agent)

  riscv_driver      drv;
  riscv_monitor     mon;
  riscv_sequencer   seqr;

  function new(string name,
               uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    drv  = riscv_driver::type_id::create("drv", this);
    mon  = riscv_monitor::type_id::create("mon", this);
    seqr = riscv_sequencer::type_id::create("seqr", this);

    is_active = UVM_ACTIVE;
  endfunction

  function void connect_phase(uvm_phase phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction

endclass


class data_mem_agent extends uvm_agent;

  `uvm_component_utils(data_mem_agent)

  riscv_monitor mon;

  function new(string name,
               uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    mon = riscv_monitor::type_id::create(
            "mon", this);

    is_active = UVM_ACTIVE;
  endfunction

endclass



