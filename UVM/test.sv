class riscv_test extends uvm_test;

  `uvm_component_utils(riscv_test)

  riscv_env           env;
  riscv_base_sequence reset_seq;
  riscv_test_sequence arith_seq;
  riscv_test_sequence mem_seq;
  riscv_test_sequence branch_seq;
  riscv_test_sequence conv_seq;  

  function new(string name = "riscv_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = riscv_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);


    reset_seq = riscv_base_sequence::type_id::create("reset_seq");
    reset_seq.start(env.instr_agnt.seqr);

    #60;


    arith_seq          = riscv_test_sequence::type_id::create("arith_seq");
    arith_seq.seq_mode = SEQ_ARITH;
    arith_seq.start(env.instr_agnt.seqr);


    #60;


    mem_seq          = riscv_test_sequence::type_id::create("mem_seq");
    mem_seq.seq_mode = SEQ_MEM;
    mem_seq.start(env.instr_agnt.seqr);

    #60;

    branch_seq          = riscv_test_sequence::type_id::create("branch_seq");
    branch_seq.seq_mode = SEQ_BRANCH;
    branch_seq.start(env.instr_agnt.seqr);

    #60;


    conv_seq          = riscv_test_sequence::type_id::create("conv_seq");
    conv_seq.seq_mode = SEQ_CONV;
    conv_seq.start(env.instr_agnt.seqr);


    #500;

    phase.drop_objection(this);

    `uvm_info("TEST", "All sequences complete — objection dropped", UVM_LOW)
  endtask

endclass