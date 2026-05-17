


class riscv_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(riscv_scoreboard)


  uvm_analysis_imp #(riscv_sequence_item,
                     riscv_scoreboard) scoreboard_port;



  riscv_sequence_item transactions[$];

  typedef struct {
    logic [31:0] addr;
    logic [31:0] data;
  } store_txn_t;

  store_txn_t store_q[$];


  logic [31:0] rf_model [32];
  logic [31:0] mem_model[bit [31:0]];


  localparam int PIPE_DEPTH = 4;

  typedef struct {
    logic [4:0]  rd;
    logic [31:0] expected;
    logic [31:0] pc;         // for error messages
  } inflight_t;

  inflight_t inflight_q[$];


  typedef enum logic [1:0] {
    CONV_IDLE,
    CONV_INIT,
    CONV_RUN,
    CONV_DONE
  } conv_state_e;

  conv_state_e conv_state;


  function new(string name = "riscv_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    scoreboard_port = new("scoreboard_port", this);

    foreach (rf_model[i]) rf_model[i] = 32'h0;
    conv_state = CONV_IDLE;
  endfunction


  function void write(riscv_sequence_item tr);
    transactions.push_back(tr);
  endfunction

  task run_phase(uvm_phase phase);
    riscv_sequence_item tr;

    forever begin
      wait(transactions.size() > 0);
      tr = transactions.pop_front();

      if (!tr.rst_n) begin
        // Reset: flush in-flight queue and model
        inflight_q.delete();
        foreach (rf_model[i]) rf_model[i] = 32'h0;
        mem_model.delete();
        conv_state = CONV_IDLE;
        continue;
      end

      // Push a prediction when a new instruction enters EX stage
      push_prediction(tr);

      // Check WB output against the oldest prediction
      check_writeback(tr);

      check_x0(tr);
      check_memory(tr);
      check_conv(tr);
      check_boundary_alu(tr);

      print_transaction(tr);
    end
  endtask


  // PUSH PREDICTION
  // Called every cycle; pushes an entry only when the EX stage
  // shows a new instruction that will write back a result.
  // We detect "new instruction in EX" by watching ex_rd_addr_o
  // and the decoded control signals.

  task push_prediction(riscv_sequence_item tr);
    inflight_t entry;

    // Only predict for instructions that produce a WB result
    // (non-memory, non-branch) and target a non-zero register.
    if (tr.ex_rd_addr_o == 5'd0) return;
    if (tr.ex_mem_read_o)        return; // handled by check_memory
    if (tr.ex_mem_write_o)       return;

    entry.rd       = tr.ex_rd_addr_o;
    entry.expected = compute_expected_alu(tr);
    entry.pc       = tr.ex_pc_o;

    inflight_q.push_back(entry);

    // Keep queue bounded to pipeline depth
    while (inflight_q.size() > PIPE_DEPTH)
      inflight_q.pop_front();

  endtask


  // CHECK WRITEBACK
  // Compare the DUT's wb_data against the oldest prediction
  // when reg_write is asserted.
  task check_writeback(riscv_sequence_item tr);
    inflight_t pred;

    if (!tr.reg_write) return;

    // x0 is handled separately
    if (tr.rd_addr == 5'd0) return;

    if (inflight_q.size() == 0) begin
      `uvm_warning("SCB",
        $sformatf("reg_write asserted but inflight_q empty (PC=%08h)",
          tr.id_pc_o))
      return;
    end

    pred = inflight_q.pop_front();

    if (tr.wb_data !== pred.expected) begin
      `uvm_error(
        "ALU_MISMATCH",
        $sformatf(
          "PC=%08h RD=x%0d DUT=%08h EXP=%08h ALU_OP=%0d RS1=%08h RS2=%08h IMM=%08h",
          pred.pc,
          pred.rd,
          tr.wb_data,
          pred.expected,
          tr.ex_alu_op_o,
          tr.ex_rs1_data_o,
          tr.ex_rs2_data_o,
          tr.ex_imm_o
        )
      )
      // FIX: update model to DUT value to avoid cascading errors
      rf_model[pred.rd] = tr.wb_data;
    end
    else begin
      `uvm_info(
        "ALU_PASS",
        $sformatf("PASS PC=%08h RD=x%0d WB=%08h",
          pred.pc, pred.rd, tr.wb_data),
        UVM_LOW
      )
      rf_model[pred.rd] = pred.expected;
    end

    // x0 always zero
    rf_model[0] = 32'h0;

  endtask


  // CHECK x0 (can never be written to with non-zero data)


  task check_x0(riscv_sequence_item tr);
    if (tr.reg_write && tr.rd_addr == 5'd0) begin
      if (tr.wb_data !== 32'h0)
        `uvm_error("X0_VIOLATION",
          $sformatf("Write to x0 with data %08h", tr.wb_data))
    end
  endtask

  // MEMORY CHECK
  // FIX: compute addr only when a memory op is active.

 task check_memory(riscv_sequence_item tr);

  logic [31:0] addr;
  store_txn_t st;

  // Only process memory operations
  if (!tr.ex_mem_read_o && !tr.ex_mem_write_o)
    return;

  // Compute effective address
  addr = tr.ex_rs1_data_o + tr.ex_imm_o;

  // STORE

  if (tr.ex_mem_write_o) begin

    // Update memory model
    mem_model[addr] = tr.ex_rs2_data_o;

    // Record store transaction
    st.addr = addr;
    st.data = tr.ex_rs2_data_o;

    store_q.push_back(st);

    `uvm_info("MEM_STORE",
      $sformatf("STORE ADDR=%08h DATA=%08h",
        addr,
        tr.ex_rs2_data_o),
      UVM_LOW)

  end

  // LOAD

  if (tr.ex_mem_read_o) begin

    if (mem_model.exists(addr)) begin

      if (tr.wb_data !== mem_model[addr])

        `uvm_error("LOAD_MISMATCH",
          $sformatf(
            "LOAD ADDR=%08h DUT=%08h EXP=%08h",
            addr,
            tr.wb_data,
            mem_model[addr]
          )
        )

      else

        `uvm_info("MEM_PASS",
          $sformatf(
            "LOAD PASS ADDR=%08h DATA=%08h",
            addr,
            tr.wb_data
          ),
          UVM_LOW)

    end

    else begin

      `uvm_warning("MEM_UNTRACKED",
        $sformatf(
          "LOAD from untracked addr=%08h (first access)",
          addr
        )
      )

    end

  end

endtask

  // BOUNDARY ALU CHECK
  // Flags whenever a result that should be zero is non-zero
  // after operating on the zero register.

  task check_boundary_alu(riscv_sequence_item tr);
    if (!tr.reg_write) return;

    // ADD/AND/OR/XOR of x0 with x0 must give 0
    if (tr.ex_rs1_addr_o == 5'd0 && tr.ex_rs2_addr_o == 5'd0) begin
      if (tr.ex_alu_op_o inside {4'd0, 4'd2, 4'd3, 4'd4}) begin
        if (tr.wb_data !== 32'h0)
          `uvm_error("BOUNDARY_ALU",
            $sformatf("x0 op x0 gave non-zero result %08h (alu_op=%0d)",
              tr.wb_data, tr.ex_alu_op_o))
      end
    end
  endtask

  // CONVOLUTION FSM CHECK

  task check_conv(riscv_sequence_item tr);
    case (conv_state)

      CONV_IDLE: begin
        if (tr.conv_start)
          `uvm_error("CONV_PROTOCOL",
            "conv_start asserted before conv_init")
        if (tr.conv_init) begin
          conv_state = CONV_INIT;
          `uvm_info("CONV", "IDLE -> INIT", UVM_LOW)
        end
      end

      CONV_INIT: begin
        if (tr.conv_start) begin
          conv_state = CONV_RUN;
          `uvm_info("CONV", "INIT -> RUN", UVM_LOW)
        end
      end

      CONV_RUN: begin
        if (tr.conv_done) begin
          conv_state = CONV_DONE;
          `uvm_info("CONV", "RUN -> DONE", UVM_LOW)
        end
      end

      CONV_DONE: begin
        if (!tr.conv_busy_o) begin
          conv_state = CONV_IDLE;
          `uvm_info("CONV", "DONE -> IDLE", UVM_LOW)
        end
      end

    endcase
  endtask

  // ALU REFERENCE MODEL

  function logic [31:0] compute_expected_alu(riscv_sequence_item tr);
    logic [31:0] a, b;

    a = tr.ex_rs1_data_o;
    b = tr.ex_alu_src_imm_o ? tr.ex_imm_o : tr.ex_rs2_data_o;

    case (tr.ex_alu_op_o)
      4'd0: return a + b;
      4'd1: return a - b;
      4'd2: return a & b;
      4'd3: return a | b;
      4'd4: return a ^ b;
      4'd5: return {31'h0, ($signed(a) < $signed(b))}; // SLT
      4'd6: return a << b[4:0];
      4'd7: return a >> b[4:0];
      default: return tr.wb_data; // unknown op — no check
    endcase
  endfunction

  // DEBUG PRINT

  task print_transaction(riscv_sequence_item tr);
    `uvm_info(
      "SCOREBOARD",
      $sformatf(
        "PC=%08h INSTR=%08h RD=x%0d WB=%08h REGW=%0b MEM_R=%0b MEM_W=%0b CONV_BUSY=%0b INFLIGHT=%0d",
        tr.id_pc_o, tr.id_instr_o, tr.rd_addr,
        tr.wb_data, tr.reg_write,
        tr.ex_mem_read_o, tr.ex_mem_write_o,
        tr.conv_busy_o, inflight_q.size()
      ),
      UVM_MEDIUM
    )
  endtask

endclass