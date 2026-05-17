`timescale 1ns / 1ps

module tb_ex_mem_top;

    reg clk;
    reg rst_n;

    // Inputs from ID/EX
    reg [31:0] ex_pc;
    reg [31:0] ex_rs1_data;
    reg [31:0] ex_rs2_data;
    reg [31:0] ex_imm;
    reg [4:0]  id_ex_rd_addr;

    // Control signals
    reg [3:0]  alu_op;
    reg        alu_src_b_sel;
    reg        conv_start;
    reg        conv_init;
    reg [2:0]  branch_type;
    reg        is_jump;
    reg        is_jalr;
    reg        mem_read_e;
    reg        mem_write_e;
    reg        reg_write_e;
    reg [1:0]  wb_sel_e;
    reg [1:0]  mem_size_e;
    reg        sign_ext_e;

    // Outputs
    wire [31:0] alu_result_m;
    wire [31:0] conv_result_m;
    wire [31:0] out_pc_plus_4_m;
    wire [31:0] rs2_data_m;
    wire [4:0]  rd_addr_m;

    wire        mem_read_m;
    wire        mem_write_m;
    wire        reg_write_m;
    wire [1:0]  wb_sel_m;
    wire [1:0]  mem_size_m;
    wire        sign_ext_m;
    wire        conv_busy_out;

    // DUT
    ex_mem_top dut (
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

        .mem_read_e(mem_read_e),
        .mem_write_e(mem_write_e),
        .reg_write_e(reg_write_e),
        .wb_sel_e(wb_sel_e),
        .mem_size_e(mem_size_e),
        .sign_ext_e(sign_ext_e),

        .alu_result_m(alu_result_m),
        .conv_result_m(conv_result_m),
        .out_pc_plus_4_m(out_pc_plus_4_m),
        .rs2_data_m(rs2_data_m),
        .rd_addr_m(rd_addr_m),

        .mem_read_m(mem_read_m),
        .mem_write_m(mem_write_m),
        .reg_write_m(reg_write_m),
        .wb_sel_m(wb_sel_m),
        .mem_size_m(mem_size_m),
        .sign_ext_m(sign_ext_m),

        .conv_busy_out(conv_busy_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Monitor
    initial begin
        $monitor(
            "TIME=%0t | ALU=%h | CONV=%h | RD=%0d | REGW=%b | BUSY=%b",
            $time,
            alu_result_m,
            conv_result_m,
            rd_addr_m,
            reg_write_m,
            conv_busy_out
        );
    end

    // Stimulus
    initial begin

        // =========================
        // RESET
        // =========================
        rst_n = 0;

        ex_pc          = 0;
        ex_rs1_data    = 0;
        ex_rs2_data    = 0;
        ex_imm         = 0;
        id_ex_rd_addr  = 0;

        alu_op         = 0;
        alu_src_b_sel  = 0;
        conv_start     = 0;
        conv_init      = 0;
        branch_type    = 0;
        is_jump        = 0;
        is_jalr        = 0;

        mem_read_e     = 0;
        mem_write_e    = 0;
        reg_write_e    = 0;
        wb_sel_e       = 0;
        mem_size_e     = 0;
        sign_ext_e     = 0;

        #20;
        rst_n = 1;

        // =========================
        // TEST 1 : ALU ADD
        // =========================
        $display("\n=========================");
        $display("TEST 1 : ALU ADD");
        $display("=========================");

        ex_pc          = 32'h00001000;
        ex_rs1_data    = 32'd10;
        ex_rs2_data    = 32'd20;
        ex_imm         = 32'd0;
        id_ex_rd_addr  = 5'd5;

        alu_op         = 4'b0000; // adjust to your ADD opcode
        alu_src_b_sel  = 0;

        conv_start     = 0;
        conv_init      = 0;

        reg_write_e    = 1;
        wb_sel_e       = 2'b00;

        #20;

        // =========================
        // TEST 2 : ALU ADD IMM
        // =========================
        $display("\n=========================");
        $display("TEST 2 : ALU ADD IMM");
        $display("=========================");

        ex_rs1_data    = 32'd50;
        ex_imm         = 32'd7;
        alu_src_b_sel  = 1;
        id_ex_rd_addr  = 5'd6;

        #20;

        // =========================
        // TEST 3 : CONV START
        // =========================
        $display("\n=========================");
        $display("TEST 3 : CONV");
        $display("=========================");

        conv_init      = 1;
        conv_start     = 1;

        ex_rs1_data    = 32'd3;
        ex_rs2_data    = 32'd4;

        id_ex_rd_addr  = 5'd10;

        #10;

        conv_init      = 0;
        conv_start     = 0;

        #100;

        // =========================
        // TEST 4 : MEMORY CONTROL
        // =========================
        $display("\n=========================");
        $display("TEST 4 : MEM CONTROL");
        $display("=========================");

        mem_read_e     = 1;
        mem_write_e    = 0;
        mem_size_e     = 2'b10;
        sign_ext_e     = 1;

        #20;

        // =========================
        // FINISH
        // =========================
        $display("\nDONE");
        #20;
        $finish;
    end

//==========================================================
// Monitor
//==========================================================
initial begin
    $monitor(
        "TIME=%0t | ALU=%h | CONV=%h | PC4=%h | RS2=%h | RD=%0d | MEM_R=%b | MEM_W=%b | REG_W=%b | WB_SEL=%b | MEM_SIZE=%b | SIGN_EXT=%b | CONV_BUSY=%b",
        $time,
        alu_result_m,
        conv_result_m,
        out_pc_plus_4_m,
        rs2_data_m,
        rd_addr_m,
        mem_read_m,
        mem_write_m,
        reg_write_m,
        wb_sel_m,
        mem_size_m,
        sign_ext_m,
        conv_busy_out
    );
end
  initial begin
    $dumpfile("waveform.vcd");
    
    $dumpvars();
  end
  
  
endmodule
`default_nettype wire