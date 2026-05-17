`timescale 1ns / 1ps

module conv #(
    parameter CONV_LATENCY = 3  
)(
    input clk,
    input rst_n,

    input        start,      // opcode 7'b0001011
    input        init,       
    input signed [31:0] a,   // RS1
    input signed [31:0] b,   // RS2

    output reg   busy,       
    output reg   done,       
    output wire signed  [31:0] result_out, // RD
    output wire [1:0] conv_status
);

    localparam IDLE = 2'b00,
               BUSY = 2'b01,
               DONE = 2'b10;

    reg [1:0]  state;
    reg signed [31:0] acc;
    reg [7:0]  count;
  	reg start_d;

    // The accumulator value is always architecturally visible to RD
    assign result_out = acc;
    assign conv_status = state;
  
    
    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            acc   <= 32'b0;    
            busy  <= 1'b0;
            done  <= 1'b0;
            count <= 8'd0;
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    busy <= 1'b0;
                    done <= 1'b0;
                    
                    start_d <= start;
					if (start & ~start_d) begin
                        state <= BUSY;
                        busy  <= 1'b1;
                        count <= (CONV_LATENCY > 0) ? (CONV_LATENCY - 1) : 0;
                
					end
                end

                BUSY: begin
                    busy <= 1'b1; 
                    done <= 1'b0;
                  if (init) 
                    acc <= a * b;
                  else 
                    acc <= acc + (a * b);
                
                    if (count == 0) begin
                        state <= DONE;
                    end else begin
                        count <= count - 1;
                    end
                end

                DONE: begin
                    done  <= 1'b1;
                  busy <= 1'b0;
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
