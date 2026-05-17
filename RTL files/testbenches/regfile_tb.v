`timescale 1ns / 1ps

module regfile_tb;

    // 1. Signals for the Register File
    reg clk;
    reg rst_n;
    reg we;
    reg [4:0] a_addr, b_addr, rd_addr;
    reg [31:0] rd_data;
    wire [31:0] a_data, b_data;

    // 2. Instantiate the Unit Under Test (UUT)
    regfile uut (
        .clk(clk),
        .rst_n(rst_n),
        .we(we),
        .a_addr(a_addr),
        .b_addr(b_addr),
        .rd_addr(rd_addr),
        .rd_data(rd_data),
        .a_data(a_data),
        .b_data(b_data)
    );

    // 3. Clock Generation (10ns period)
    always #5 clk = ~clk;

    initial begin
        // --- Setup for GTKWave ---
        $dumpfile("simulation.vcd"); 
        $dumpvars(0, regfile_tb);    

        // --- Initialize Signals ---
        clk = 0;
        rst_n = 0;   
        we = 0;
        a_addr = 0;
        b_addr = 0;
        rd_addr = 0;
        rd_data = 0;

        // 4. Release Reset
        #15 rst_n = 1; 

        // --- TEST 1: Write to Register x1 ---
        @(posedge clk);
        // Using non-blocking (<=) here prevents the Icarus race condition
        we <= 1;
        rd_addr <= 5'd1;     
        rd_data <= 32'hAAAA_BBBB;
        
        // --- TEST 2: Write to Register x2 ---
        @(posedge clk);
        rd_addr <= 5'd2;     
        rd_data <= 32'h1234_5678;

        // --- TEST 3: Attempt to write to x0 ---
        @(posedge clk);
        rd_addr <= 5'd0;     
        rd_data <= 32'hFFFF_FFFF;

        // --- TEST 4: Read them back ---
        @(posedge clk);
        we <= 0;             
        // Give the read addresses a tiny delay or use non-blocking
        a_addr <= 5'd1;      
        b_addr <= 5'd2;      

        // --- TEST 5: Read x0 ---
        // Wait one more clock cycle to see the stable result of Test 4
        @(posedge clk);
        a_addr <= 5'd0;      
        
        #30;
        $display("Test Complete. Check GTKWave!");
        $finish;
    end

endmodule