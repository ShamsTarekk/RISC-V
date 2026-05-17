`ifndef RISCV_DEFS_VH
`define RISCV_DEFS_VH

// ============================================================
// SAFE NOP
// ============================================================
`define RISCV_NOP 32'h00000013   // ADDI x0, x0, 0

// ============================================================
// OPCODES
// ============================================================
`define OPCODE_LOAD      7'b0000011
`define OPCODE_MISC_MEM  7'b0001111
`define OPCODE_OP_IMM    7'b0010011
`define OPCODE_AUIPC     7'b0010111
`define OPCODE_STORE     7'b0100011
`define OPCODE_OP        7'b0110011
`define OPCODE_LUI       7'b0110111
`define OPCODE_BRANCH    7'b1100011
`define OPCODE_JALR      7'b1100111
`define OPCODE_JAL       7'b1101111
`define OPCODE_SYSTEM    7'b1110011
`define OPCODE_CUSTOM0   7'b0001011

// ============================================================
// ALU OPERATIONS
// ============================================================
`define ALU_ADD   4'b0000
`define ALU_SUB   4'b0001
`define ALU_SLL   4'b0010
`define ALU_SLT   4'b0011
`define ALU_SLTU  4'b0100
`define ALU_XOR   4'b0101
`define ALU_SRL   4'b0110
`define ALU_SRA   4'b0111
`define ALU_OR    4'b1000
`define ALU_AND   4'b1001

// ============================================================
// WRITEBACK SELECT
// ============================================================
`define WB_ALU    2'b00
`define WB_MEM    2'b01
`define WB_CONV   2'b10
`define WB_PC4    2'b11

// ============================================================
// OPERAND A SELECT
// ============================================================
`define OP_A_RS1   2'b00
`define OP_A_PC    2'b01
`define OP_A_ZERO  2'b10

// ============================================================
// MEMORY ACCESS SIZE
// ============================================================
`define MEM_BYTE  2'b00
`define MEM_HALF  2'b01
`define MEM_WORD  2'b10

// ============================================================
// LOAD/STORE FUNCT3
// ============================================================

// LOADS
`define FUNCT3_LB    3'b000
`define FUNCT3_LH    3'b001
`define FUNCT3_LW    3'b010
`define FUNCT3_LBU   3'b100
`define FUNCT3_LHU   3'b101

// STORES
`define FUNCT3_SB    3'b000
`define FUNCT3_SH    3'b001
`define FUNCT3_SW    3'b010

// ============================================================
// BRANCH TYPES
// ============================================================
`define BR_BEQ   3'b000
`define BR_BNE   3'b001
`define BR_BLT   3'b100
`define BR_BGE   3'b101
`define BR_BLTU  3'b110
`define BR_BGEU  3'b111

// ============================================================
// SYSTEM FUNCT3
// ============================================================
`define SYS_ECALL_EBREAK 3'b000
`define SYS_CSRRW         3'b001
`define SYS_CSRRS         3'b010
`define SYS_CSRRC         3'b011
`define SYS_CSRRWI        3'b101
`define SYS_CSRRSI        3'b110
`define SYS_CSRRCI        3'b111

// ============================================================
// CONV STATUS
// ============================================================
`define CONV_IDLE  2'b00
`define CONV_BUSY  2'b01
`define CONV_DONE  2'b10

// ============================================================
// FUNCT7 VALUES
// ============================================================
`define FUNCT7_ADD   7'b0000000
`define FUNCT7_SUB   7'b0100000
`define FUNCT7_SRA   7'b0100000

// ============================================================
// BOOLEAN HELPERS
// ============================================================
`define TRUE  1'b1
`define FALSE 1'b0

`endif