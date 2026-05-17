//==============================================================================
// imem.v — Instruction Memory (64-byte version)
//==============================================================================

`timescale 1ns / 1ps
`default_nettype none

module imem #(
    parameter integer DEPTH_WORDS = 16,          // 64 bytes / 4 = 16 words
    parameter integer ADDR_WIDTH  = 6,          // log2(64) = 6 bits
    parameter         HEX_FILE    = "program.hex",
    parameter [31:0]  NOP_DEFAULT = 32'h00000013
) (
    input  wire        clk,
    input  wire [31:0] addr,
    output reg  [31:0] instr
);

    // -------------------------------------------------------------------------
    // Instruction storage (16 words = 64 bytes)
    // -------------------------------------------------------------------------
    reg [31:0] mem [0:DEPTH_WORDS-1];

    integer i;
    initial begin
        for (i = 0; i < DEPTH_WORDS; i = i + 1) begin
            mem[i] = NOP_DEFAULT;
        end
        $readmemh(HEX_FILE, mem);
    end

    // -------------------------------------------------------------------------
    // Word index (ignore lower 2 bits)
    // -------------------------------------------------------------------------
    wire [ADDR_WIDTH-3:0] word_index = addr[ADDR_WIDTH-1:2];

    // -------------------------------------------------------------------------
    // Synchronous read
    // -------------------------------------------------------------------------
    always @(posedge clk) begin
        instr <= mem[word_index];
    end

endmodule

`default_nettype wire