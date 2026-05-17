`timescale 1ns/1ps
`default_nettype none
`include "riscv_defs.vh"

//------------------------------------------------------------------------------
// IF/ID pipeline register.
// Flush inserts NOP. Stall holds the current register contents.
// Flush has priority over stall to satisfy FLUSH_SAFE-style behavior.
//------------------------------------------------------------------------------
module if_id_reg (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        stall_i,
    input  wire        flush_i,

    input  wire [31:0] if_pc_i,
    input  wire [31:0] if_pc4_i,
    input  wire [31:0] if_instr_i,

    output reg  [31:0] id_pc_o,
    output reg  [31:0] id_pc4_o,
    output reg  [31:0] id_instr_o
);

    always @(posedge clk) begin
        if (!rst_n) begin
            id_pc_o    <= 32'h00000000;
            id_pc4_o   <= 32'h00000004;
            id_instr_o <= `RISCV_NOP;
        end else if (flush_i) begin
            id_pc_o    <= 32'h00000000;
            id_pc4_o   <= 32'h00000004;
            id_instr_o <= `RISCV_NOP;
        end else if (stall_i) begin
            id_pc_o    <= id_pc_o;
            id_pc4_o   <= id_pc4_o;
            id_instr_o <= id_instr_o;
        end else begin
            id_pc_o    <= if_pc_i;
            id_pc4_o   <= if_pc4_i;
            id_instr_o <= if_instr_i;
        end
    end

endmodule

`default_nettype wire
