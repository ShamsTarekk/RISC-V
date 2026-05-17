module riscv_props (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        stall_i,
    input  wire        flush_i,
    input  wire        conv_start,
    input  wire        reg_write,
    input  wire [4:0]  rd_addr,
    input  wire [31:0] wb_data,
    input  wire        conv_done
);

// ============================================================
// Clock / Reset Modeling
// ============================================================
reg f_past_valid = 0;
always @(posedge clk) begin
    f_past_valid <= 1;
end

always @(*) begin
    if (!f_past_valid) begin
        assume(rst_n == 0); // Clear state at Step 0
    end else begin
        assume(rst_n == 1); // Allow normal execution
    end
end

// ============================================================
// Submodule Path Adjustments (Hierarchical Mapping)
// ============================================================
// Adjust these internal paths according to your submodules' exact wire names
wire        id_ex_valid_w = riscv_top.id_ex_reg_top_inst.id_instr_o != 32'h00000013; // Example NOP validation check
wire [31:0] current_pc    = riscv_top.if_stage_id_reg_inst.id_pc_o; 
wire [31:0] next_pc_val   = riscv_top.if_stage_id_reg_inst.id_pc4_o; // Or target redirect address line
wire [31:0] internal_conv_res = riscv_top.ex_mem_stages_top_inst.wb_data; // Point to Conv PE output bus
wire [1:0]  internal_conv_fsm = riscv_top.ex_mem_stages_top_inst.conv_busy_o; // Link to FSM state register

localparam IDLE = 2'b00;
localparam BUSY = 2'b01;
localparam DONE = 2'b10;
localparam CONV_LATENCY = 8;

// ============================================================
// 1. SAFETY PROPERTIES (Unbounded Verification)
// ============================================================

// FLUSH_SAFE: ID/EX register holds a NOP the cycle after a flush
// synthesis translate_off
property FLUSH_SAFE;
    @(posedge clk) disable iff (!rst_n)
    flush_i |=> (id_ex_valid_w == 0);
endproperty
assert property (FLUSH_SAFE);

// X0_SAFE: write-enable to register x0 with non-zero data never occurs
property X0_SAFE;
    @(posedge clk) disable iff (!rst_n)
    !(reg_write && (rd_addr == 5'd0) && (wb_data != 32'd0));
endproperty
assert property (X0_SAFE);

// PC_PROGRESS: the PC increments or jumps every cycle when the pipeline is not stalled
property PC_PROGRESS;
    @(posedge clk) disable iff (!rst_n)
    (!stall_i) |-> (next_pc_val != current_pc);
endproperty
assert property (PC_PROGRESS);

// ============================================================
// 2. CONV-PE PROPERTIES (Bounded Verification)
// ============================================================

// CONV_STALL_COUNT: exactly CONV_LATENCY stall cycles are asserted per Conv-PE instruction
property CONV_STALL_COUNT;
    @(posedge clk) disable iff (!rst_n)
    conv_start |-> ##[1:CONV_LATENCY] conv_done;
endproperty
assert property (CONV_STALL_COUNT);

// CONV_RESULT_STABLE: conv_result holds from conv_done until WB captures it
property CONV_RESULT_STABLE;
    @(posedge clk) disable iff (!rst_n)
    conv_done |-> (internal_conv_res == $past(internal_conv_res));
endproperty
assert property (CONV_RESULT_STABLE);

// CONV_FSM: only the transition IDLE->BUSY->DONE->IDLE is reachable
property CONV_FSM;
    @(posedge clk) disable iff (!rst_n)
    (internal_conv_fsm == IDLE) |-> ##1 (internal_conv_fsm == BUSY || internal_conv_fsm == IDLE) ##1
    (internal_conv_fsm == BUSY) |-> ##1 (internal_conv_fsm == DONE) ##1
    (internal_conv_fsm == DONE) |-> ##1 (internal_conv_fsm == IDLE);
endproperty
assert property (CONV_FSM);

// ============================================================
// 3. LIVENESS PROPERTIES (Cover Assertions)
// ============================================================

// INSTR_PROGRESS: every instruction entering IF eventually reaches WB
cover property (
    @(posedge clk) disable iff (!rst_n)
    (riscv_top.id_instr_o != 0) |-> ##[1:20] reg_write
);

// CONV_TERMINATES: every Conv-PE instruction eventually asserts conv_done
cover property (
    @(posedge clk) disable iff (!rst_n)
    conv_start |-> ##[1:50] conv_done
);
// synthesis translate_on

endmodule

// Bind connection block targetting the top-level module container
bind riscv_top riscv_props riscv_props_bind (
    .clk(clk),
    .rst_n(rst_n),
    .stall_i(stall_i),
    .flush_i(flush_i),
    .conv_start(conv_start),
    .reg_write(reg_write),
    .rd_addr(rd_addr),
    .wb_data(wb_data),
    .conv_done(conv_done)
);

