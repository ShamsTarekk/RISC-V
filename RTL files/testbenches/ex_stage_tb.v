`timescale 1ns / 1ps

module tb_ex_stage;

// ---------------- DUT INPUTS ----------------
reg clk;
reg rst_n;

reg [31:0] ex_pc;
reg [31:0] ex_rs1_data;
reg [31:0] ex_rs2_data;
reg [31:0] ex_imm;
reg [4:0]  id_ex_rd_addr;

reg [3:0]  alu_op;
reg        alu_src_b_sel;

reg        conv_start;
reg        conv_init;

reg [2:0]  branch_type;
reg        is_jump;
reg        is_jalr;

// ---------------- DUT OUTPUTS ----------------
wire [31:0] branch_target_pc;
wire        branch_taken;

wire [31:0] alu_result;
wire [31:0] conv_result;
wire [31:0] out_pc_plus_4;
wire [31:0] ex_store_data;
wire [4:0]  ex_mem_rd_addr;

wire        conv_busy;
wire        done;
wire [1:0]  conv_status;

// ---------------- SCOREBOARD ----------------
integer pass;
integer fail;

// expected values
reg expected_branch;
reg [31:0] expected_alu;
reg [31:0] expected_jal;
reg [31:0] expected_jalr;
reg [31:0] expected_conv;

// ---------------- DUT ----------------
ex_stage dut (
    .clk(clk),
    .rst_n(rst_n),

    .ex_pc(ex_pc),
    .ex_rs1_data(ex_rs1_data),
    .ex_rs2_data(ex_rs2_data),
    .ex_imm(ex_imm),
    .id_ex_rd_addr(id_ex_rd_addr),

    .alu_op(alu_op),
    .alu_src_b_sel(alu_src_b_sel),

    .conv_start(conv_start),
    .conv_init(conv_init),

    .branch_type(branch_type),
    .is_jump(is_jump),
    .is_jalr(is_jalr),

    .branch_target_pc(branch_target_pc),
    .branch_taken(branch_taken),

    .alu_result(alu_result),
    .conv_result(conv_result),
    .out_pc_plus_4(out_pc_plus_4),
    .ex_store_data(ex_store_data),
    .ex_mem_rd_addr(ex_mem_rd_addr),

    .conv_busy(conv_busy),
    .done(done),
    .conv_status(conv_status)
);

// ---------------- CLOCK ----------------
always #5 clk = ~clk;

// ---------------- TEST ----------------
initial begin
    $dumpfile("ex_stage.vcd");
    $dumpvars(0);

    pass = 0;
    fail = 0;

    clk = 0;
    rst_n = 0;

    ex_pc = 0;
    ex_rs1_data = 0;
    ex_rs2_data = 0;
    ex_imm = 0;
    id_ex_rd_addr = 0;

    alu_op = 0;
    alu_src_b_sel = 0;

    conv_start = 0;
    conv_init = 0;

    branch_type = 0;
    is_jump = 0;
    is_jalr = 0;

    #10;
    rst_n = 1;

    // ==================================================
    // 1. BEQ
    // ==================================================
    ex_rs1_data = 10;
    ex_rs2_data = 10;
    branch_type = 3'b000;
    expected_branch = 1;

    #10;

    $display("\n[BEQ]");
    $display("INPUT  rs1=%d rs2=%d", ex_rs1_data, ex_rs2_data);
    $display("EXPECTED branch_taken=%b", expected_branch);
    $display("ACTUAL   branch_taken=%b", branch_taken);

    if (branch_taken == expected_branch) begin
        $display("RESULT: PASS");
        pass = pass + 1;
    end else begin
        $display("RESULT: FAIL");
        fail = fail + 1;
    end

    // ==================================================
    // 2. BNE
    // ==================================================
    ex_rs1_data = 5;
    ex_rs2_data = 5;
    branch_type = 3'b001;
    expected_branch = 0;

    #10;

    $display("\n[BNE]");
    $display("INPUT  rs1=%d rs2=%d", ex_rs1_data, ex_rs2_data);
    $display("EXPECTED branch_taken=%b", expected_branch);
    $display("ACTUAL   branch_taken=%b", branch_taken);

    if (branch_taken == expected_branch) begin
        $display("RESULT: PASS");
        pass = pass + 1;
    end else begin
        $display("RESULT: FAIL");
        fail = fail + 1;
    end

    // ==================================================
    // 3. BLT
    // ==================================================
    ex_rs1_data = -5;
    ex_rs2_data = 3;
    branch_type = 3'b100;
    expected_branch = 1;

    #10;

    $display("\n[BLT]");
    $display("INPUT  rs1=%d rs2=%d", ex_rs1_data, ex_rs2_data);
    $display("EXPECTED branch_taken=%b", expected_branch);
    $display("ACTUAL   branch_taken=%b", branch_taken);

    if (branch_taken == expected_branch) begin
        $display("RESULT: PASS");
        pass = pass + 1;
    end else begin
        $display("RESULT: FAIL");
        fail = fail + 1;
    end

    // ==================================================
    // 4. BGE
    // ==================================================
    ex_rs1_data = 10;
    ex_rs2_data = 5;
    branch_type = 3'b101;
    expected_branch = 1;

    #10;

    $display("\n[BGE]");
    $display("INPUT  rs1=%d rs2=%d", ex_rs1_data, ex_rs2_data);
    $display("EXPECTED branch_taken=%b", expected_branch);
    $display("ACTUAL   branch_taken=%b", branch_taken);

    if (branch_taken == expected_branch) begin
        $display("RESULT: PASS");
        pass = pass + 1;
    end else begin
        $display("RESULT: FAIL");
        fail = fail + 1;
    end

    // ==================================================
    // 5. BLTU
    // ==================================================
    ex_rs1_data = 1;
    ex_rs2_data = 2;
    branch_type = 3'b110;
    expected_branch = 1;

    #10;

    $display("\n[BLTU]");
    $display("INPUT  rs1=%d rs2=%d", ex_rs1_data, ex_rs2_data);
    $display("EXPECTED branch_taken=%b", expected_branch);
    $display("ACTUAL   branch_taken=%b", branch_taken);

    if (branch_taken == expected_branch) begin
        $display("RESULT: PASS");
        pass = pass + 1;
    end else begin
        $display("RESULT: FAIL");
        fail = fail + 1;
    end

    // ==================================================
    // 6. BGEU
    // ==================================================
    ex_rs1_data = 10;
    ex_rs2_data = 1;
    branch_type = 3'b111;
    expected_branch = 1;

    #10;

    $display("\n[BGEU]");
    $display("INPUT  rs1=%d rs2=%d", ex_rs1_data, ex_rs2_data);
    $display("EXPECTED branch_taken=%b", expected_branch);
    $display("ACTUAL   branch_taken=%b", branch_taken);

    if (branch_taken == expected_branch) begin
        $display("RESULT: PASS");
        pass = pass + 1;
    end else begin
        $display("RESULT: FAIL");
        fail = fail + 1;
    end

    // ==================================================
    // 7. JAL
    // ==================================================
    is_jump = 1;
    ex_pc = 100;
    ex_imm = 20;
    expected_jal = 120;

    #10;

    $display("\n[JAL]");
    $display("INPUT  pc=%d imm=%d", ex_pc, ex_imm);
    $display("EXPECTED target=%h", expected_jal);
    $display("ACTUAL   target=%h", branch_target_pc);

    if (branch_target_pc == expected_jal) begin
        $display("RESULT: PASS");
        pass = pass + 1;
    end else begin
        $display("RESULT: FAIL");
        fail = fail + 1;
    end

    is_jump = 0;

    // ==================================================
    // 8. JALR
    // ==================================================
    is_jalr = 1;
    ex_rs1_data = 32'h1000;
    ex_imm = 5;
    expected_jalr = (32'h1000 + 5) & ~32'b1;

    #10;

    $display("\n[JALR]");
    $display("INPUT  rs1=%h imm=%d", ex_rs1_data, ex_imm);
    $display("EXPECTED target=%h", expected_jalr);
    $display("ACTUAL   target=%h", branch_target_pc);

    if (branch_target_pc == expected_jalr) begin
        $display("RESULT: PASS");
        pass = pass + 1;
    end else begin
        $display("RESULT: FAIL");
        fail = fail + 1;
    end

    is_jalr = 0;

    // ==================================================
    // 9. ALU
    // ==================================================
    alu_op = 4'b0000;
    ex_rs1_data = 10;
    ex_rs2_data = 20;
    alu_src_b_sel = 0;
    expected_alu = 30;

    #10;

    $display("\n[ALU]");
    $display("INPUT  a=%d b=%d", ex_rs1_data, ex_rs2_data);
    $display("EXPECTED=%d", expected_alu);
    $display("ACTUAL  =%d", alu_result);

    if (alu_result == expected_alu) begin
        $display("RESULT: PASS");
        pass = pass + 1;
    end else begin
        $display("RESULT: FAIL");
        fail = fail + 1;
    end

    // ==================================================
    // 10. CONV
    // ==================================================
    conv_init = 1;
    conv_start = 1;
    ex_rs1_data = 3;
    ex_rs2_data = 4;
    expected_conv = 12;

    #10;
    conv_init = 0;
    conv_start = 0;

    repeat(5) #10;

    $display("\n[CONV]");
    $display("INPUT  a=%d b=%d", ex_rs1_data, ex_rs2_data);
    $display("EXPECTED=%d", expected_conv);
    $display("ACTUAL  =%d", conv_result);

    if (conv_result == expected_conv) begin
        $display("RESULT: PASS");
        pass = pass + 1;
    end else begin
        $display("RESULT: FAIL");
        fail = fail + 1;
    end

      // ==================================================
    // 9. ALU
    // ==================================================
    alu_op = 4'b0000;
    ex_rs1_data = 10;
    ex_rs2_data = 20;
    alu_src_b_sel = 0;
    expected_alu = 30;

    #10;

    $display("\n[ALU]");
    $display("INPUT  a=%d b=%d", ex_rs1_data, ex_rs2_data);
    $display("EXPECTED=%d", expected_alu);
    $display("ACTUAL  =%d", alu_result);

    if (alu_result == expected_alu) begin
        $display("RESULT: PASS");
        pass = pass + 1;
    end else begin
        $display("RESULT: FAIL");
        fail = fail + 1;
    end

    // ==================================================
    // 10. CONV
    // ==================================================
    conv_init = 1;
    conv_start = 1;
    ex_rs1_data = 3;
    ex_rs2_data = 4;
    expected_conv = 12;

    #10;
    conv_init = 0;
    conv_start = 0;

    repeat(5) #10;

    $display("\n[CONV]");
    $display("INPUT  a=%d b=%d", ex_rs1_data, ex_rs2_data);
    $display("EXPECTED=%d", expected_conv);
    $display("ACTUAL  =%d", conv_result);

    if (conv_result == expected_conv) begin
        $display("RESULT: PASS");
        pass = pass + 1;
    end else begin
        $display("RESULT: FAIL");
        fail = fail + 1;
    end
// ==================================================
    // 11. Parallelism Check
    // ==================================================
    $display("\n[PARALLEL CHECK]");
    ex_rs1_data = 32'd10;
    ex_rs2_data = 32'd5;
    alu_op      = 4'b0000; // ADD
    conv_init   = 1;
    conv_start  = 1;       // Start CONV
    
    #2; // Wait a tiny bit for combinational logic to settle
    
    $display("At T=%0t: ALU is doing 10+5 = %d", $time, alu_result);
    $display("At T=%0t: CONV is starting 10*5...", $time);
    
    if (alu_result == 15) 
        $display("RESULT: PASS - ALU processed inputs immediately while CONV started.");
    
    // Now wait for CONV to finish
    wait(done);
    #1;
    if (conv_result == 50)
        $display("RESULT: PASS - CONV finished later with correct result.");
    // ==================================================
    // SUMMARY
    // ==================================================
    $display("\n================================");
    $display("FINAL SCORE");
    $display("PASS = %d", pass);
    $display("FAIL = %d", fail);
    $display("================================");

    #20;   // instead of smaller delay
    $finish;
end

endmodule