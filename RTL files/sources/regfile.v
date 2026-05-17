`timescale 1ns / 1ps

module regfile (
    input clk,                 
    input rst_n,               
    input we,               
    input  [4:0]  a_addr, b_addr,     
    input  [4:0]  rd_addr,    
    input  [31:0] rd_data,       
    output reg [31:0] a_data, b_data 
);

// reg [31:0] registers [31:1];
// integer i; 

// //(Asynchronous Read)
// always @(*) begin
//     if (a_addr == 5'd0) begin
//         a_data = 32'd0; 
//     end else begin
//         a_data = registers[a_addr];
//     end
    
//     if (b_addr == 5'd0) begin
//         b_data = 32'd0; 
//     end else begin
//         b_data = registers[b_addr]; 
//     end
// end

// //(Synchronous Write)
// always @(posedge clk) begin
// if (rst_n == 1'b0) begin
//     for (i = 1; i <= 31; i = i + 1)
//         registers[i] <= 32'd0;
  
//   // preload registers
//   registers[10] <= 32'd10;   
//   registers[30] <= 32'd5;   



// end else if (we == 1'b1 && rd_addr != 5'd0) begin
//         registers[rd_addr] <= rd_data;
//     end
// end

// endmodule
  reg [31:0] registers [31:0];

integer i, k;

// ----------------------------------------------------
// Asynchronous read
// ----------------------------------------------------
always @(*) begin
    a_data = (a_addr == 5'd0) ? 32'd0 : registers[a_addr];
    b_data = (b_addr == 5'd0) ? 32'd0 : registers[b_addr];
end

// ----------------------------------------------------
// Synchronous write + initialization
// ----------------------------------------------------
always @(posedge clk) begin
    if (!rst_n) begin
        // Optional: safe reset (not strictly needed if using $readmemh)
      registers[0] <= 32'd0;
        for (i = 1; i < 32; i = i + 1)
          registers[i] <= i+1;
    end
    else if (we && rd_addr != 5'd0) begin
        registers[rd_addr] <= rd_data;
    end

end


endmodule