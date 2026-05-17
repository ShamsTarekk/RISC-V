`timescale 1ns/1ps
`default_nettype none
`include "riscv_defs.vh"
`include "imem.v"

//------------------------------------------------------------------------------
// IF stage: PC register + next-PC mux + instruction memory access.
// Uses provided imem.v, which has synchronous registered output.
//------------------------------------------------------------------------------
module if_stage #(
    parameter HEX_FILE = "program.hex"
) (
    input  wire        clk,
    input  wire        rst_n,

    // Global pipeline controls
    input  wire        stall_i,          // freeze PC while Conv-PE is busy
    input  wire        redirect_valid_i, // branch/JAL/JALR taken in EX
    input  wire [31:0] redirect_pc_i,

    // Output toward IF/ID pipeline register
    output wire [31:0] if_pc_o,
    output wire [31:0] if_pc4_o,
    output wire [31:0] if_instr_o
);

    reg [31:0] pc_q;
    reg [31:0] pc_for_instr_q;
    wire [31:0] imem_instr;

    assign if_pc_o      = pc_for_instr_q;
    assign if_pc4_o     = pc_for_instr_q + 32'd4;
    assign if_instr_o   = imem_instr;

    imem #(
        .HEX_FILE(HEX_FILE)
    ) u_imem (
        .clk   (clk),
        .addr  (pc_q),
        .instr (imem_instr)
    );

    always @(posedge clk) begin
      if (!rst_n) begin
            pc_q           <= 32'h00000000;
            pc_for_instr_q <= 32'h00000000;
        end else if (stall_i) begin
            pc_q           <= pc_q;
            pc_for_instr_q <= pc_for_instr_q;
        end else begin
            pc_for_instr_q <= pc_q;

            if (redirect_valid_i) begin
                pc_q <= redirect_pc_i;
            end else begin
                pc_q <= pc_q + 32'd4;
            end
        end
    end

endmodule

`default_nettype wire
