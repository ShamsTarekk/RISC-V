`timescale 1ns/1ps
`default_nettype none
`include "riscv_defs.vh"

//------------------------------------------------------------------------------
// RV32I immediate generator.
//------------------------------------------------------------------------------
module imm_gen (
    input  wire [31:0] instr_i,
    output reg  [31:0] imm_o
);

    wire [6:0] opcode;
    assign opcode = instr_i[6:0];

    always @* begin
        imm_o = 32'h00000000;
        case (opcode)
            `OPCODE_OP_IMM,
            `OPCODE_LOAD,
            `OPCODE_JALR,
            `OPCODE_SYSTEM: begin
                // I-type
                imm_o = {{20{instr_i[31]}}, instr_i[31:20]};
            end

            `OPCODE_STORE: begin
                // S-type
                imm_o = {{20{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};
            end

            `OPCODE_BRANCH: begin
                // B-type, LSB is always zero
                imm_o = {{19{instr_i[31]}}, instr_i[31], instr_i[7],
                         instr_i[30:25], instr_i[11:8], 1'b0};
            end

            `OPCODE_LUI,
            `OPCODE_AUIPC: begin
                // U-type
                imm_o = {instr_i[31:12], 12'b0};
            end

            `OPCODE_JAL: begin
                // J-type, LSB is always zero
                imm_o = {{11{instr_i[31]}}, instr_i[31], instr_i[19:12],
                         instr_i[20], instr_i[30:21], 1'b0};
            end

            default: begin
                imm_o = 32'h00000000;
            end
        endcase
    end

endmodule

`default_nettype wire
