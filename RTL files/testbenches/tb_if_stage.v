`timescale 1ns/1ps
`default_nettype none
`include "riscv_defs.vh"

module tb_if_stage;
    reg clk;
    reg rst_n;
    reg stall;
    reg redirect_valid;
    reg [31:0] redirect_pc;
    wire [31:0] if_pc;
    wire [31:0] if_pc4;
    wire [31:0] if_instr;
    wire [31:0] pc_current;
    integer pass_count;
    integer fail_count;

    if_stage #(.HEX_FILE("program.hex")) dut (
        .clk(clk), .rst_n(rst_n), .stall_i(stall),
        .redirect_valid_i(redirect_valid), .redirect_pc_i(redirect_pc),
        .if_pc_o(if_pc), .if_pc4_o(if_pc4), .if_instr_o(if_instr),
        .pc_current_o(pc_current)
    );

    always #5 clk = ~clk;

    task check;
        input condition;
        input [255:0] name;
        begin
            if (condition) begin
                $display("PASS: %0s", name);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: %0s", name);
                $display("      pc_current=%h if_pc=%h if_pc4=%h if_instr=%h", pc_current, if_pc, if_pc4, if_instr);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("sim/tb_if_stage.vcd");
        $dumpvars(0, tb_if_stage);
        clk = 0;
        rst_n = 0;
        stall = 0;
        redirect_valid = 0;
        redirect_pc = 32'h00000000;
        pass_count = 0;
        fail_count = 0;

        @(posedge clk); #1;
        check(pc_current == 32'h00000000 && if_pc == 32'h00000000, "reset PC is zero");

        rst_n = 1;
        @(posedge clk); #1;
        check(pc_current == 32'h00000004 && if_pc == 32'h00000000 && if_instr == 32'h00500093, "first fetch: PC advanced, instruction belongs to address 0");

        @(posedge clk); #1;
        check(pc_current == 32'h00000008 && if_pc == 32'h00000004 && if_instr == 32'h002081b3, "second fetch increments PC by 4");

        stall = 1;
        @(posedge clk); #1;
        check(pc_current == 32'h00000008 && if_pc == 32'h00000004, "stall freezes PC and IF outputs");

        stall = 0;
        redirect_valid = 1;
        redirect_pc = 32'h00000020;
        @(posedge clk); #1;
        check(pc_current == 32'h00000020, "redirect updates PC to branch/jump target");

        redirect_valid = 0;
        @(posedge clk); #1;
        check(pc_current == 32'h00000024 && if_pc == 32'h00000020, "after redirect, PC increments from target");

        if (fail_count == 0)
            $display("ALL tb_if_stage CHECKS PASSED. pass=%0d", pass_count);
        else
            $display("tb_if_stage FAILED. fail=%0d pass=%0d", fail_count, pass_count);
        $finish;
    end
endmodule

`default_nettype wire
