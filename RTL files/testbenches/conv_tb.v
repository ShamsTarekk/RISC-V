`timescale 1ns / 1ps

module conv_tb;
    // Parameter matching the UUT
    parameter CONV_LATENCY = 3;

    // Testbench Signals
    reg clk;
    reg rst_n;
    reg start;
    reg init;
    reg signed [31:0] a;
    reg signed [31:0] b;

    wire busy;
    wire done;
    wire signed [31:0] result_out; // Explicitly signed
    wire [1:0] conv_status;

    // Performance tracking for Phase 0 report
    real start_time; 

    // Unit Under Test (UUT)
    conv #( .CONV_LATENCY(CONV_LATENCY) ) uut (
        .clk(clk), 
        .rst_n(rst_n), 
        .start(start), 
        .init(init), 
        .a(a), 
        .b(b), 
        .busy(busy), 
        .done(done), 
        .result_out(result_out),
        .conv_status(conv_status)
    );

    // 100 MHz Clock Generation (10ns period)
    always #5 clk = ~clk;

    initial begin
        // Setup Waveform Dumping for Phase 0 requirements
        $dumpfile("simulation.vcd"); 
        $dumpvars(0, conv_tb);
        
        // Start latency tracking
        start_time = $realtime;
        
        // Initialize Inputs
        clk = 0; rst_n = 0; start = 0; init = 0; a = 0; b = 0;
        
        // Apply Reset
        #20 rst_n = 1; 
        #10;

        // --- TEST 1: Initializing MAC (init = 1) ---
        // Expected: 10 * 20 = 200
        @(posedge clk); start <= 1; init <= 1; a <= 32'd10; b <= 32'd20;
        @(posedge clk); start <= 0; init <= 0;
        wait(done); @(posedge clk);
        $display("[TIME %0t] TEST 1: Result = %d (Exp: 200)", $time, result_out);

        // --- TEST 2: Accumulate Negative Result (init = 0) ---
        // Expected: 200 + (5 * -10) = 150
        @(posedge clk); start <= 1; init <= 0; a <= 32'd5; b <= -32'd10;
        @(posedge clk); start <= 0;
        wait(done); @(posedge clk);
        $display("[TIME %0t] TEST 2: Result = %d (Exp: 150)", $time, result_out);

        // --- TEST 3: Edge Case Zero (init = 0) ---
        // Expected: 150 + (0 * 50) = 150
        @(posedge clk); start <= 1; init <= 0; a <= 32'd0; b <= 32'd50;
        @(posedge clk); start <= 0;
        wait(done); @(posedge clk);
        $display("[TIME %0t] TEST 3: Result = %d (Exp: 150)", $time, result_out);

        // --- TEST 4: Accumulate Large Positive (init = 0) ---
        // Expected: 150 + (-8 * -8) = 150 + 64 = 214
        @(posedge clk); start <= 1; init <= 0; a <= -32'd8; b <= -32'd8;
        @(posedge clk); start <= 0;
        wait(done); @(posedge clk);
        $display("[TIME %0t] TEST 4: Result = %d (Exp: 214)", $time, result_out);

        // --- TEST 5: Re-Init Overwrite (init = 1) ---
        // Expected: 1 * 100 = 100 (Previous 214 is discarded)
        @(posedge clk); start <= 1; init <= 1; a <= 32'd1; b <= 32'd100;
        @(posedge clk); start <= 0;
        wait(done); @(posedge clk);
        $display("[TIME %0t] TEST 5: Result = %d (Exp: 100)", $time, result_out);

        // --- TEST 6: Continuous Overwrite (init = 1) ---
        // Expected: 5 * 100 = 500
        @(posedge clk); start <= 1; init <= 1; a <= 32'd5; b <= 32'd100;
        @(posedge clk); start <= 0;
        wait(done); @(posedge clk);
        $display("[TIME %0t] TEST 6: Result = %d (Exp: 500)", $time, result_out);


        @(posedge clk); start <= 1; init <= 1; a <= 32'd5; b <= -32'd10;
        @(posedge clk); start <= 0;
        wait(done); @(posedge clk);
        $display("[TIME %0t] TEST 7: Result = %d (Exp: -50)", $time, result_out);

        // Required Report Metrics
        #50;
        $finish;
    end
endmodule