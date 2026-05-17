`timescale 1ns / 1ps

module tb_id_ex_reg_top;

    //====================================================
    // CLOCK + RESET
    //====================================================
    reg clk;
    reg rst_n;

    //====================================================
    // INPUTS TO DUT
    //====================================================
    reg  [31:0] id_pc_i;
    reg  [31:0] id_pc4_i;
    reg  [31:0] id_instr_i;
    reg         flush_i;

    // WB → REGFILE
    reg         reg_write;
    reg  [4:0]  rd_addr;
    reg  [31:0] wb_data;

    //====================================================
    // OUTPUTS FROM DUT
    //====================================================
    wire [31:0] ex_pc_o;
    wire [31:0] ex_pc4_o;

    wire [31:0] ex_rs1_data_o;
    wire [31:0] ex_rs2_data_o;
    wire [31:0] ex_imm_o;

    wire [4:0]  ex_rs1_addr_o;
    wire [4:0]  ex_rs2_addr_o;
    wire [4:0]  ex_rd_addr_o;

    wire        ex_reg_write_o;
    wire        ex_mem_read_o;
    wire        ex_mem_write_o;

    wire [1:0]  ex_mem_size_o;
    wire        ex_mem_sign_ext_o;
    wire [1:0]  ex_wb_sel_o;

    wire [3:0]  ex_alu_op_o;
    wire        ex_alu_src_imm_o;

    wire        ex_jump_o;
    wire        ex_jalr_o;

    wire        ex_is_conv_o;
    wire        ex_conv_init_o;

    //====================================================
    // DUT
    //====================================================
    id_ex_reg_top dut (

        .clk(clk),
        .rst_n(rst_n),

        .id_pc_i(id_pc_i),
        .id_pc4_i(id_pc4_i),
        .id_instr_i(id_instr_i),
        .flush_i(flush_i),

        .reg_write(reg_write),
        .rd_addr(rd_addr),
        .wb_data(wb_data),

        .ex_pc_o(ex_pc_o),
        .ex_pc4_o(ex_pc4_o),

        .ex_rs1_data_o(ex_rs1_data_o),
        .ex_rs2_data_o(ex_rs2_data_o),
        .ex_imm_o(ex_imm_o),

        .ex_rs1_addr_o(ex_rs1_addr_o),
        .ex_rs2_addr_o(ex_rs2_addr_o),
        .ex_rd_addr_o(ex_rd_addr_o),

        .ex_reg_write_o(ex_reg_write_o),
        .ex_mem_read_o(ex_mem_read_o),
        .ex_mem_write_o(ex_mem_write_o),

        .ex_mem_size_o(ex_mem_size_o),
        .ex_mem_sign_ext_o(ex_mem_sign_ext_o),
        .ex_wb_sel_o(ex_wb_sel_o),

        .ex_alu_op_o(ex_alu_op_o),
        .ex_alu_src_imm_o(ex_alu_src_imm_o),

        .ex_jump_o(ex_jump_o),
        .ex_jalr_o(ex_jalr_o),

        .ex_is_conv_o(ex_is_conv_o),
        .ex_conv_init_o(ex_conv_init_o)
    );

    //====================================================
    // CLOCK
    //====================================================
    always #5 clk = ~clk;

    //====================================================
    // MONITOR
    //====================================================
    initial begin

        $display("\nTIME | PC | INSTR | RS1 | RS2 | RD | REGW | ALU_OP | CONV");

        $display("--------------------------------------------------------------------------------");

        $monitor(
            "%4t | %h | %h | %h | %h | %0d | %b | %h | %b",
            $time,

            ex_pc_o,
            id_instr_i,

            ex_rs1_data_o,
            ex_rs2_data_o,

            ex_rd_addr_o,

            ex_reg_write_o,
            ex_alu_op_o,

            ex_is_conv_o
        );

    end

    //====================================================
    // STIMULUS
    //====================================================
    initial begin

        // init
        clk       = 0;
        rst_n     = 0;

        id_pc_i   = 0;
        id_pc4_i  = 0;
        id_instr_i = 0;

        flush_i   = 0;

        reg_write = 0;
        rd_addr   = 0;
        wb_data   = 0;

        //================================================
        // RESET
        //================================================
        #20;
        rst_n = 1;

        //================================================
        // WRITE x1 = 10
        //================================================
        @(posedge clk);
        reg_write <= 1;
        rd_addr   <= 5'd1;
        wb_data   <= 32'd10;
      #30;

        //================================================
        // WRITE x2 = 20
        //================================================
        @(posedge clk);
        rd_addr   <= 5'd2;
        wb_data   <= 32'd20;

        //================================================
        // STOP WRITING
        //================================================
        @(posedge clk);
        reg_write <= 0;

      
        //================================================
        // TEST 1 : ADDI/NOP
        //================================================
        @(posedge clk);

        id_pc_i    <= 32'h00000000;
        id_pc4_i   <= 32'h00000004;
        id_instr_i <= 32'h00000013;

        //================================================
        // TEST 2 : R-TYPE ADD
        // add x10,x10,x11
        //================================================
        @(posedge clk);

        id_pc_i    <= 32'h00000004;
        id_pc4_i   <= 32'h00000008;
        id_instr_i <= 32'h00b50533;

        //================================================
        // TEST 3 : CONV INSTRUCTION
        //================================================
        @(posedge clk);

        id_pc_i    <= 32'h00000008;
        id_pc4_i   <= 32'h0000000C;
        id_instr_i <= 32'h0000000B;

        //================================================
        // TEST 4 : FLUSH
        //================================================
        @(posedge clk);

        flush_i    <= 1;
       	id_instr_i <= 32'h00000013;

        @(posedge clk);

        flush_i <= 0;
      	id_instr_i <= 32'h00000013;
      	

        //================================================
        // END SIM
        //================================================
        #40;
        $finish;

    end

  initial begin
    $dumpfile("waveform.vcd");
    
    $dumpvars();
  end
  
  
endmodule
`default_nettype wire