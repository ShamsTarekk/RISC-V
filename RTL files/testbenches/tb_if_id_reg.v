`timescale 1ns/1ps
`default_nettype none
`include "riscv_defs.vh"

module tb_if_id_reg;
    reg clk;
    reg rst_n;
    reg stall;
    reg flush;
    reg [31:0] if_pc;
    reg [31:0] if_pc4;
    reg [31:0] if_instr;
    wire [31:0] id_pc;
    wire [31:0] id_pc4;
    wire [31:0] id_instr;
    integer pass_count;
    integer fail_count;

    if_id_reg dut (
        .clk(clk), .rst_n(rst_n), .stall_i(stall), .flush_i(flush),
        .if_pc_i(if_pc), .if_pc4_i(if_pc4), .if_instr_i(if_instr),
        .id_pc_o(id_pc), .id_pc4_o(id_pc4), .id_instr_o(id_instr)
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
                $display("      id_pc=%h id_pc4=%h id_instr=%h", id_pc, id_pc4, id_instr);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("sim/tb_if_id_reg.vcd");
        $dumpvars(0, tb_if_id_reg);
        clk = 0;
        rst_n = 0;
        stall = 0;
        flush = 0;
        if_pc = 32'h00000000;
        if_pc4 = 32'h00000004;
        if_instr = 32'hdeadbeef;
        pass_count = 0;
        fail_count = 0;

        @(posedge clk); #1;
        check(id_instr == `RISCV_NOP && id_pc == 32'h00000000 && id_pc4 == 32'h00000004, "reset inserts NOP");

        rst_n = 1;
        if_pc = 32'h00000020;
        if_pc4 = 32'h00000024;
        if_instr = 32'h00500093;
        @(posedge clk); #1;
        check(id_pc == 32'h00000020 && id_pc4 == 32'h00000024 && id_instr == 32'h00500093, "normal load captures IF values");

        stall = 1;
        if_pc = 32'h00000030;
        if_pc4 = 32'h00000034;
        if_instr = 32'h002081b3;
        @(posedge clk); #1;
        check(id_pc == 32'h00000020 && id_instr == 32'h00500093, "stall holds previous values");

        stall = 0;
        flush = 1;
        @(posedge clk); #1;
        check(id_instr == `RISCV_NOP && id_pc == 32'h00000000, "flush inserts NOP");

        // This RTL gives flush priority over stall, which helps the formal FLUSH_SAFE property.
        stall = 1;
        flush = 1;
        if_pc = 32'h00000040;
        if_instr = 32'h12345678;
        @(posedge clk); #1;
        check(id_instr == `RISCV_NOP && id_pc == 32'h00000000, "flush priority over stall");

        if (fail_count == 0)
            $display("ALL tb_if_id_reg CHECKS PASSED. pass=%0d", pass_count);
        else
            $display("tb_if_id_reg FAILED. fail=%0d pass=%0d", fail_count, pass_count);
        $finish;
    end
endmodule

`default_nettype wire
