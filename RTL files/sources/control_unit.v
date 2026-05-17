`timescale 1ns/1ps
`default_nettype none
`include "riscv_defs.vh"

//------------------------------------------------------------------------------
// RV32I + custom-0 Conv-PE control decode.
// Pure combinational logic. No latches.
//------------------------------------------------------------------------------
module control_unit (
    input  wire [6:0] opcode_i,
    input  wire [2:0] funct3_i,
    input  wire [6:0] funct7_i,

    output reg        reg_write_o,
    output reg        mem_read_o,
    output reg        mem_write_o,
    output reg [1:0]  mem_size_o,
    output reg        mem_sign_ext_o,
    output reg [1:0]  wb_sel_o,
    output reg [3:0]  alu_op_o,
    output reg        alu_src_imm_o,
    output reg [1:0]  op_a_sel_o,

    output reg        branch_o,
    output reg [2:0]  branch_type_o,

    output reg        jump_o,
    output reg        jalr_o,

    output reg        is_lui_o,
    output reg        is_auipc_o,

    output reg        is_conv_o,
    output reg        conv_init_o,

    output reg        illegal_o,
  output reg halt_o
);

  
always @* begin

    // ============================================================
    // SAFE DEFAULTS
    // ============================================================
    reg_write_o    = 1'b0;
    mem_read_o     = 1'b0;
    mem_write_o    = 1'b0;
  halt_o = 1'b0;
    mem_size_o     = `MEM_WORD;
    mem_sign_ext_o = 1'b1;

    wb_sel_o       = `WB_ALU;

    alu_op_o       = `ALU_ADD;
    alu_src_imm_o  = 1'b0;
    op_a_sel_o     = `OP_A_RS1;

    branch_o       = 1'b0;
    branch_type_o  = 3'b000;

    jump_o         = 1'b0;
    jalr_o         = 1'b0;

    is_lui_o       = 1'b0;
    is_auipc_o     = 1'b0;

    is_conv_o      = 1'b0;
    conv_init_o    = 1'b0;

    illegal_o      = 1'b0;

    // ============================================================
    // OPCODE DECODE
    // ============================================================
    case (opcode_i)

        // ========================================================
        // R-TYPE
        // ========================================================
        `OPCODE_OP: begin

            reg_write_o   = 1'b1;
            alu_src_imm_o = 1'b0;
            op_a_sel_o    = `OP_A_RS1;
            wb_sel_o      = `WB_ALU;

            case (funct3_i)

                3'b000: begin
                    if (funct7_i == 7'b0000000)
                        alu_op_o = `ALU_ADD;
                    else if (funct7_i == 7'b0100000)
                        alu_op_o = `ALU_SUB;
                    else
                        illegal_o = 1'b1;
                end

                3'b001: begin
                    alu_op_o = `ALU_SLL;
                    if (funct7_i != 7'b0000000)
                        illegal_o = 1'b1;
                end

                3'b010: begin
                    alu_op_o = `ALU_SLT;
                    if (funct7_i != 7'b0000000)
                        illegal_o = 1'b1;
                end

                3'b011: begin
                    alu_op_o = `ALU_SLTU;
                    if (funct7_i != 7'b0000000)
                        illegal_o = 1'b1;
                end

                3'b100: begin
                    alu_op_o = `ALU_XOR;
                    if (funct7_i != 7'b0000000)
                        illegal_o = 1'b1;
                end

                3'b101: begin
                    if (funct7_i == 7'b0000000)
                        alu_op_o = `ALU_SRL;
                    else if (funct7_i == 7'b0100000)
                        alu_op_o = `ALU_SRA;
                    else
                        illegal_o = 1'b1;
                end

                3'b110: begin
                    alu_op_o = `ALU_OR;
                    if (funct7_i != 7'b0000000)
                        illegal_o = 1'b1;
                end

                3'b111: begin
                    alu_op_o = `ALU_AND;
                    if (funct7_i != 7'b0000000)
                        illegal_o = 1'b1;
                end

                default: begin
                    illegal_o = 1'b1;
                end

            endcase
        end

        // ========================================================
        // I-TYPE ALU
        // ========================================================
        `OPCODE_OP_IMM: begin

            reg_write_o   = 1'b1;
            alu_src_imm_o = 1'b1;
            op_a_sel_o    = `OP_A_RS1;
            wb_sel_o      = `WB_ALU;

            case (funct3_i)

                3'b000: alu_op_o = `ALU_ADD;   // ADDI
                3'b010: alu_op_o = `ALU_SLT;   // SLTI
                3'b011: alu_op_o = `ALU_SLTU;  // SLTIU
                3'b100: alu_op_o = `ALU_XOR;   // XORI
                3'b110: alu_op_o = `ALU_OR;    // ORI
                3'b111: alu_op_o = `ALU_AND;   // ANDI

                3'b001: begin
                    alu_op_o = `ALU_SLL;
                    if (funct7_i != 7'b0000000)
                        illegal_o = 1'b1;
                end

                3'b101: begin
                    if (funct7_i == 7'b0000000)
                        alu_op_o = `ALU_SRL;
                    else if (funct7_i == 7'b0100000)
                        alu_op_o = `ALU_SRA;
                    else
                        illegal_o = 1'b1;
                end

                default: illegal_o = 1'b1;

            endcase
        end

        // ========================================================
        // LOAD
        // ========================================================
        `OPCODE_LOAD: begin

            reg_write_o    = 1'b1;
            mem_read_o     = 1'b1;
            mem_write_o    = 1'b0;

            alu_src_imm_o  = 1'b1;
            op_a_sel_o     = `OP_A_RS1;
            alu_op_o       = `ALU_ADD;

            wb_sel_o       = `WB_MEM;

            case (funct3_i)

                3'b000: begin
                    mem_size_o     = `MEM_BYTE;
                    mem_sign_ext_o = 1'b1;
                end

                3'b001: begin
                    mem_size_o     = `MEM_HALF;
                    mem_sign_ext_o = 1'b1;
                end

                3'b010: begin
                    mem_size_o     = `MEM_WORD;
                    mem_sign_ext_o = 1'b1;
                end

                3'b100: begin
                    mem_size_o     = `MEM_BYTE;
                    mem_sign_ext_o = 1'b0;
                end

                3'b101: begin
                    mem_size_o     = `MEM_HALF;
                    mem_sign_ext_o = 1'b0;
                end

                default: begin
                    illegal_o  = 1'b1;
                    mem_read_o = 1'b0;
                end

            endcase
        end

        // ========================================================
        // STORE
        // ========================================================
        `OPCODE_STORE: begin

            reg_write_o   = 1'b0;
            mem_write_o   = 1'b1;
            mem_read_o    = 1'b0;

            alu_src_imm_o = 1'b1;
            op_a_sel_o    = `OP_A_RS1;
            alu_op_o      = `ALU_ADD;

            case (funct3_i)

                3'b000: mem_size_o = `MEM_BYTE;
                3'b001: mem_size_o = `MEM_HALF;
                3'b010: mem_size_o = `MEM_WORD;

                default: begin
                    illegal_o   = 1'b1;
                    mem_write_o = 1'b0;
                end

            endcase
        end

        // ========================================================
        // BRANCH
        // ========================================================
        `OPCODE_BRANCH: begin

            reg_write_o   = 1'b0;

            branch_o      = 1'b1;
            branch_type_o = funct3_i;

            alu_src_imm_o = 1'b0;
            op_a_sel_o    = `OP_A_RS1;

            alu_op_o      = `ALU_SUB;

            case (funct3_i)

                3'b000, // BEQ
                3'b001, // BNE
                3'b100, // BLT
                3'b101, // BGE
                3'b110, // BLTU
                3'b111: begin // BGEU
                    illegal_o = 1'b0;
                end

                default: begin
                    branch_o      = 1'b0;
                    branch_type_o = 3'b000;
                    illegal_o     = 1'b1;
                end

            endcase
        end

        // ========================================================
        // JAL
        // ========================================================
        `OPCODE_JAL: begin

            reg_write_o   = 1'b1;

            jump_o        = 1'b1;
            jalr_o        = 1'b0;

            wb_sel_o      = `WB_PC4;

            op_a_sel_o    = `OP_A_PC;
            alu_src_imm_o = 1'b1;
            alu_op_o      = `ALU_ADD;
        end

        // ========================================================
        // JALR
        // ========================================================
        `OPCODE_JALR: begin

            reg_write_o   = 1'b1;

            jump_o        = 1'b1;
            jalr_o        = 1'b1;

            wb_sel_o      = `WB_PC4;

            op_a_sel_o    = `OP_A_RS1;
            alu_src_imm_o = 1'b1;
            alu_op_o      = `ALU_ADD;

            if (funct3_i != 3'b000)
                illegal_o = 1'b1;
        end

        // ========================================================
        // LUI
        // ========================================================
        `OPCODE_LUI: begin

            reg_write_o   = 1'b1;
            is_lui_o      = 1'b1;

            wb_sel_o      = `WB_ALU;

            op_a_sel_o    = `OP_A_ZERO;
            alu_src_imm_o = 1'b1;
            alu_op_o      = `ALU_ADD;
        end

        // ========================================================
        // AUIPC
        // ========================================================
        `OPCODE_AUIPC: begin

            reg_write_o   = 1'b1;
            is_auipc_o    = 1'b1;

            wb_sel_o      = `WB_ALU;

            op_a_sel_o    = `OP_A_PC;
            alu_src_imm_o = 1'b1;
            alu_op_o      = `ALU_ADD;
        end

        // ========================================================
        // CUSTOM CONV PE
        // ========================================================
        `OPCODE_CUSTOM0: begin

            if ((funct3_i == 3'b000) &&
                (funct7_i[6:1] == 6'b000000)) begin

                reg_write_o   = 1'b1;

                is_conv_o     = 1'b1;
                conv_init_o   = funct7_i[0];

                wb_sel_o      = `WB_CONV;

                alu_src_imm_o = 1'b0;
                op_a_sel_o    = `OP_A_RS1;

                alu_op_o      = `ALU_ADD;

            end
            else begin
                illegal_o = 1'b1;
              halt_o = 1'b0;
            end
        end
      `OPCODE_SYSTEM: begin
        if (funct3_i == 3'b000 && funct7_i == 7'b0000001) begin
        	illegal_o = 1'b0;  // treat as HALT
        	halt_o = 1'b1;
        end
			end

        // ========================================================
        // DEFAULT
        // ========================================================
        default: begin
            illegal_o = 1'b1;
          	halt_o = 1'b0;
        end

    endcase
end

endmodule

`default_nettype wire