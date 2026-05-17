`timescale 1ns/1ps

module tb_if_stage_id_reg;

    reg clk;
    reg rst_n;

    reg stall_i;
    reg flush_i;
    reg redirect_valid_i;
    reg [31:0] redirect_pc_i;

    wire [31:0] id_pc_o;
    wire [31:0] id_pc4_o;
    wire [31:0] id_instr_o;

    // DUT
    if_stage_id_reg dut (
        .clk(clk),
        .rst_n(rst_n),
        .stall_i(stall_i),
        .flush_i(flush_i),
        .redirect_valid_i(redirect_valid_i),
        .redirect_pc_i(redirect_pc_i),
        .id_pc_o(id_pc_o),
        .id_pc4_o(id_pc4_o),
        .id_instr_o(id_instr_o)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Monitor
    initial begin
        $display("TIME | PC | PC+4 | INSTR | stall flush redirect");
        $monitor("%4t | %h | %h | %h |   %b      %b      %b",
                 $time, id_pc_o, id_pc4_o, id_instr_o,
                 stall_i, flush_i, redirect_valid_i);
    end

    initial begin
        // Init
        clk = 0;
        rst_n = 0;

        stall_i = 0;
        flush_i = 0;
        redirect_valid_i = 0;
        redirect_pc_i = 32'h0;

        // Reset
        #20;
        rst_n = 1;

        // -------------------------
        // 1. Normal fetch
        // -------------------------
        #50;

        // -------------------------
        // 2. Stall pipeline
        // -------------------------
        stall_i = 1;
        #40;
        stall_i = 0;
      #10;

        // -------------------------
        // 3. Flush (simulate bubble after mispredict)
        // -------------------------
        flush_i = 1;
        #30;
        flush_i = 0;

        // -------------------------
        // 4. Redirect (branch/jump)
        // -------------------------
        redirect_valid_i = 1;
        redirect_pc_i = 32'h00000080;
        #10;
        redirect_valid_i = 0;

        // Let pipeline settle
        #100;

        $finish;
    end

  initial begin
    $dumpfile("waveform.vcd");
    
    $dumpvars();
  end
  
  
endmodule
`default_nettype wire