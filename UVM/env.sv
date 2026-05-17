class riscv_env extends uvm_env;

  `uvm_component_utils(riscv_env)

  instr_mem_agent      instr_agnt;
  data_mem_agent       data_agnt;
  conv_pe_monitor      conv_mon;

  riscv_scoreboard     scb;
  riscv_coverage       cov;

  function new(string name = "riscv_env",
               uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    instr_agnt = instr_mem_agent::type_id::create(
                  "instr_agnt", this);

    data_agnt = data_mem_agent::type_id::create(
                  "data_agnt", this);

    conv_mon = conv_pe_monitor::type_id::create(
                 "conv_mon", this);

    scb = riscv_scoreboard::type_id::create(
            "scb", this);

    cov = riscv_coverage::type_id::create(
            "cov", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    instr_agnt.mon.monitor_port.connect(
      scb.scoreboard_port);

    data_agnt.mon.monitor_port.connect(
      scb.scoreboard_port);

    conv_mon.monitor_port.connect(
      scb.scoreboard_port);

    instr_agnt.mon.monitor_port.connect(
      cov.cov_port);

    data_agnt.mon.monitor_port.connect(
      cov.cov_port);

    conv_mon.monitor_port.connect(
      cov.cov_port);
  endfunction

endclass
