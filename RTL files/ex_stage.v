`timescale 1ns / 1ps
`include "alu.v"
`include "conv.v"
module ex_stage (
    input clk,
    input rst_n,

    // 1. Inputs from ID/EX Pipeline Register
    input [31:0] ex_pc,
    input [31:0] ex_rs1_data,
    input [31:0] ex_rs2_data,
    input [31:0] ex_imm,
    input [4:0]  id_ex_rd_addr,
    
    // 2. Control Signals from ID Stage
    input [3:0]  alu_op,          
    input        alu_src_b_sel,   
    input        conv_start,   
    input        conv_init,   
    input [2:0]  branch_type,     
    input        is_jump,         
    input        is_jalr,         // Required for the target_base logic
     
    // 4. Outputs to IF Stage (PC Logic)
    output [31:0] branch_target_pc,
    output        branch_taken,    

    // 5. Outputs to EX/MEM Pipeline Register (Late Mux Style)
    output [31:0] alu_result,   // Separated for Late Mux
    output [31:0] conv_result,  // Separated for Late Mux
    output [31:0] out_pc_plus_4,    // Separated for Late Mux
    output [31:0] ex_store_data,   
    output [4:0]  ex_mem_rd_addr,
    
    // 7. Pipeline Stall Logic
    output        conv_busy,done,       
    output [1:0]  conv_status      
);

// Internal Signals
reg  [31:0] b; 
wire [31:0] alu_result_wire;
wire [31:0] conv_result_wire;
wire        zero_flag;
reg         branch_decision;
reg [31:0] target_base_r;
reg [31:0] branch_target_pc_r;

// Step 1: ALU Operand Mux
always @* begin
    if (alu_src_b_sel == 1'b1)
        b = ex_imm;
    else
        b = ex_rs2_data;
end

alu alu_inst (
    .a(ex_rs1_data), 
    .b(b), 
    .select(alu_op), 
    .result(alu_result_wire), 
    .zero_flag(zero_flag)
);

conv #(
    .CONV_LATENCY(4) 
) conv_inst (
    .clk(clk),
    .rst_n(rst_n),
    .start(conv_start),
    .init(conv_init),
    .a(ex_rs1_data),
    .b(ex_rs2_data),   
    .busy(conv_busy),  
    .done(done),
    .result_out(conv_result_wire),
    .conv_status(conv_status)
);

always @* begin

    // Base address selection
    if (is_jalr)
        target_base_r = ex_rs1_data;
    else
        target_base_r = ex_pc;

    // Target calculation
    branch_target_pc_r = target_base_r + ex_imm;

    // JALR requires bit[0] = 0
    if (is_jalr)
        branch_target_pc_r = branch_target_pc_r & ~32'b1;
end

assign branch_target_pc = branch_target_pc_r;

always @* begin
    case(branch_type)
        3'b000:  branch_decision = (ex_rs1_data == ex_rs2_data);          // BEQ
        3'b001:  branch_decision = (ex_rs1_data != ex_rs2_data);          // BNE
        3'b100:  branch_decision = ($signed(ex_rs1_data) < $signed(ex_rs2_data)); 
        3'b101:  branch_decision = ($signed(ex_rs1_data) >= $signed(ex_rs2_data));
        3'b110:  branch_decision = (ex_rs1_data < ex_rs2_data);           // BLTU
        3'b111:  branch_decision = (ex_rs1_data >= ex_rs2_data);          // BGEU
        default: branch_decision = 1'b0;
    endcase
end
assign branch_taken = is_jump ? 1'b1 : branch_decision;

// Step 4: Final Output Assignments (Routing results to the EX/MEM Register)
assign alu_result     = alu_result_wire;
assign conv_result    = conv_result_wire;
assign out_pc_plus_4  = ex_pc + 4;
assign ex_store_data  = ex_rs2_data;
assign ex_mem_rd_addr = id_ex_rd_addr;


endmodule

//assign conv_start = (opcode == 7'b0001011) && !pipeline_stall_from_elsewhere;

