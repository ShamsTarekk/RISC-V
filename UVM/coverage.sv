

class riscv_coverage extends uvm_component;

  `uvm_component_utils(riscv_coverage)


  uvm_analysis_imp #(riscv_sequence_item,
                     riscv_coverage) cov_port;

  riscv_sequence_item tr;


  bit valid_sample;

  // Conv-FSM state tracker (mirrors scoreboard FSM)
  // Used by cg_conv_transitions to sample state arcs.

  typedef enum logic [1:0] {
    CV_IDLE,
    CV_INIT,
    CV_RUN,
    CV_DONE
  } cov_conv_state_e;

  cov_conv_state_e conv_state;
  cov_conv_state_e conv_state_prev;

  // COVERGROUP: INSTRUCTION / ISA

  covergroup cg_riscv_instr;
    option.per_instance = 1;

    cp_opcode: coverpoint tr.id_instr_o[6:0] {
      bins R_TYPE = {7'b0110011};
      bins I_TYPE = {7'b0010011};
      bins LOAD   = {7'b0000011};
      bins STORE  = {7'b0100011};
      bins BRANCH = {7'b1100011};
      bins JAL    = {7'b1101111};
      bins JALR   = {7'b1100111};
      bins LUI    = {7'b0110111};
      bins AUIPC  = {7'b0010111};
      bins SYSTEM = {7'b1110011};   
      bins OTHER = default;
    }

    cp_alu_op: coverpoint tr.ex_alu_op_o {
      bins ADD     = {0};
      bins SUB     = {1};
      bins AND     = {2};
      bins OR      = {3};
      bins XOR     = {4};
      bins SLT     = {5};
      bins SHIFT_L = {6};
      bins SHIFT_R = {7};
      bins OTHER = default; 
    }

    cross cp_opcode, cp_alu_op;

  endgroup

  // =========================================================
  // COVERGROUP: MEMORY
  // =========================================================

  covergroup cg_mem;
    option.per_instance = 1;

    cp_mem_read: coverpoint tr.ex_mem_read_o {
      bins READ = {1};
      bins IDLE = {0};
    }

    cp_mem_write: coverpoint tr.ex_mem_write_o {
      bins WRITE = {1};
      bins IDLE  = {0};
    }

    cp_mem_size: coverpoint tr.ex_mem_size_o {
      bins BYTE     = {2'b00};
      bins HALFWORD = {2'b01};
      bins WORD     = {2'b10};
    }

    cp_mem_conflict: coverpoint {tr.ex_mem_read_o, tr.ex_mem_write_o} {
      bins READ_ONLY  = {2'b10};
      bins WRITE_ONLY = {2'b01};
      bins NEITHER    = {2'b00};
      illegal_bins BOTH = {2'b11};  // read+write same cycle is illegal
    }

    cross cp_mem_read, cp_mem_write;

  endgroup



  covergroup cg_branch;
    option.per_instance = 1;

    cp_branch_type: coverpoint tr.branch_type {
      bins BEQ  = {3'd0};
      bins BNE  = {3'd1};
      bins BLT  = {3'd2};
      bins BGE  = {3'd3};
      bins BLTU = {3'd4};
      bins BGEU = {3'd5};
    }

    cp_jump: coverpoint tr.ex_jump_o {
      bins NO_JUMP = {0};
      bins JUMP    = {1};
    }

    cp_jalr: coverpoint tr.ex_jalr_o {
      bins NO_JALR = {0};
      bins JALR    = {1};
    }

    cp_jump_conflict: coverpoint {tr.ex_jump_o, tr.ex_jalr_o} {
      bins JAL_ONLY  = {2'b10};
      bins JALR_ONLY = {2'b01};
      bins NEITHER   = {2'b00};
      illegal_bins BOTH = {2'b11};
    }

    cross cp_branch_type, cp_jump;

  endgroup



  covergroup cg_conv;
    option.per_instance = 1;

    cp_conv_init: coverpoint tr.conv_init {
      bins INIT_ON  = {1};
      bins INIT_OFF = {0};
    }

    cp_conv_start: coverpoint tr.conv_start {
      bins START_ON  = {1};
      bins START_OFF = {0};
    }

    cp_conv_busy: coverpoint tr.conv_busy_o {
      bins BUSY = {1};
      bins IDLE = {0};
    }

    cp_conv_done: coverpoint tr.conv_done {
      bins DONE     = {1};
      bins NOT_DONE = {0};
    }

    cp_done_busy: coverpoint {tr.conv_done, tr.conv_busy_o} {
      bins DONE_AND_BUSY    = {2'b11};  // legal: done while still busy
      bins BUSY_NOT_DONE    = {2'b01};
      bins NEITHER          = {2'b00};
      illegal_bins DONE_NO_BUSY = {2'b10}; // done without busy is illegal
    }

    cross cp_conv_init, cp_conv_start, cp_conv_done;

  endgroup


  covergroup cg_conv_transitions;
    option.per_instance = 1;

    cp_conv_state_arc: coverpoint conv_state {
      // All four valid state arcs
      bins idle_to_init = (CV_IDLE  => CV_INIT);
      bins init_to_run  = (CV_INIT  => CV_RUN );
      bins run_to_done  = (CV_RUN   => CV_DONE);
      bins done_to_idle = (CV_DONE  => CV_IDLE);
      // Self-loop bins (staying in a state for multiple cycles)
      bins idle_idle    = (CV_IDLE  => CV_IDLE);
      bins init_init    = (CV_INIT  => CV_INIT);
      bins run_run      = (CV_RUN   => CV_RUN );
      bins done_done    = (CV_DONE  => CV_DONE);
    }

  endgroup


  covergroup cg_alu_boundary;
    option.per_instance = 1;

    cp_rs1_boundary: coverpoint tr.ex_rs1_data_o {
      bins ZERO     = {32'h0000_0000};
      bins ALL_ONES = {32'hFFFF_FFFF};
      bins INT_MAX  = {32'h7FFF_FFFF};
      bins INT_MIN  = {32'h8000_0000};
      bins OTHER    = default;
    }

    cp_rs2_boundary: coverpoint tr.ex_rs2_data_o {
      bins ZERO      = {32'h0000_0000};
      bins MAX_SHIFT = {32'h0000_001F}; // shift by 31
      bins ALL_ONES  = {32'hFFFF_FFFF};
      bins OTHER     = default;
    }

    cp_alu_op_boundary: coverpoint tr.ex_alu_op_o {
      bins ADD  = {4'd0};
      bins SUB  = {4'd1};
      bins SLL  = {4'd6};
      bins SRL  = {4'd7};
    }

    // Cross: zero input with each ALU op
    cross cp_rs1_boundary, cp_alu_op_boundary;
    cross cp_rs2_boundary, cp_alu_op_boundary;

  endgroup



  covergroup cg_pipeline;
    option.per_instance = 1;

    cp_stall: coverpoint tr.stall_i {
      bins STALL = {1};
      bins RUN   = {0};
    }

    cp_flush: coverpoint tr.flush_i {
      bins FLUSH    = {1};
      bins NO_FLUSH = {0};
    }

    cp_redirect: coverpoint tr.redirect_valid_i {
      bins REDIRECT = {1};
      bins NORMAL   = {0};
    }

    cross cp_stall,    cp_flush;
    cross cp_redirect, cp_flush;

  endgroup


  function new(string name, uvm_component parent);
    super.new(name, parent);

    cg_riscv_instr      = new();
    cg_mem              = new();
    cg_branch           = new();
    cg_conv             = new();
    cg_conv_transitions = new();
    cg_alu_boundary     = new();
    cg_pipeline         = new();

    conv_state      = CV_IDLE;
    conv_state_prev = CV_IDLE;
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    cov_port = new("cov_port", this);
  endfunction


  function void write(riscv_sequence_item t);
    tr = t;

    // Skip reset cycles
    if (!tr.rst_n) begin
      conv_state      = CV_IDLE;
      conv_state_prev = CV_IDLE;
      return;
    end

    // Skip X-polluted cycles
    valid_sample = 1;
    if (tr.id_pc_o === 'x) valid_sample = 0;
    if (!valid_sample) return;

    conv_state_prev = conv_state;

    case (conv_state)
      CV_IDLE: if (tr.conv_init)                conv_state = CV_INIT;
      CV_INIT: if (tr.conv_start)               conv_state = CV_RUN;
      CV_RUN:  if (tr.conv_done)                conv_state = CV_DONE;
      CV_DONE: if (!tr.conv_busy_o)             conv_state = CV_IDLE;
    endcase

    cg_riscv_instr.sample();
    cg_mem.sample();
    cg_branch.sample();
    cg_conv.sample();
    cg_conv_transitions.sample();
    cg_alu_boundary.sample();
    cg_pipeline.sample();

  endfunction

endclass