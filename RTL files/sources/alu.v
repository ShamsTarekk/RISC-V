`timescale 1ns / 1ps

module alu (
    input  [31:0] a, b,
    input  [3:0]  select,
    output reg [31:0] result,
    output zero_flag
);

assign zero_flag = (result == 32'b0);
always @(*) begin
    result = a + b;
    case (select)

        4'b0000: result = a + b;                  // ADD (Addition)
        4'b0001: result = a - b;                  // SUB (Subtraction)
        4'b0010: result = a << b[4:0];            // SLL (Shift Left Logical)
        4'b0011: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // SLT  (Set Less Than - Signed)
        4'b0100: result = (a < b) ? 32'd1 : 32'd0;                  // SLTU (Set Less Than - Unsigned)
        4'b0101: result = a ^ b;                  // XOR (Bitwise Exclusive OR)
        4'b0110: result = a >> b[4:0];            // SRL (Shift Right Logical)
        4'b0111: result = $signed(a) >>> b[4:0];  // SRA (Shift Right Arithmetic)
        4'b1000: result = a | b;                  // OR  (Bitwise OR)
        4'b1001: result = a & b;                  // AND (Bitwise AND)
        
        default: result = a + b;               // Default/Reserved

    endcase
end

endmodule
