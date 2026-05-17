//==============================================================================
// dmem.v — Data Memory (64-byte version)
//==============================================================================

`timescale 1ns / 1ps
`default_nettype none

module dmem #(
    // -------------------------------------------------------------------------
    // MODIFIED: 4KB -> 64 bytes
    // -------------------------------------------------------------------------
    parameter integer DEPTH_BYTES = 64,     // 64 bytes total memory
    parameter integer ADDR_WIDTH  = 6,      // log2(64) = 6
    parameter         HEX_FILE    = "data.hex",
    parameter [31:0]  ZERO_FILL   = 32'h00000000
) (
    // Clock
    input  wire        clk,

    // Write port
    input  wire        we,
    input  wire [1:0]  wsize,
    input  wire [31:0] waddr,
    input  wire [31:0] wdata,

    // Read port (combinational)
    input  wire [31:0] raddr,
    input  wire [1:0]  rsize,
    input  wire        sign_ext,
    output reg  [31:0] rdata
);

    // -------------------------------------------------------------------------
    // Byte-addressed memory
    // -------------------------------------------------------------------------
    reg [7:0] mem [0:DEPTH_BYTES-1];

    // -------------------------------------------------------------------------
    // Address indexing (SAFE for 64 bytes)
    // -------------------------------------------------------------------------
    wire [ADDR_WIDTH-1:0] w_idx = waddr[5:0];
    wire [ADDR_WIDTH-1:0] r_idx = raddr[5:0];

    // -------------------------------------------------------------------------
    // Memory initialization
    // -------------------------------------------------------------------------
    integer i;
    initial begin
        for (i = 0; i < DEPTH_BYTES; i = i + 1) begin
            mem[i] = 8'h00;
        end

        $readmemh(HEX_FILE, mem);

        // synthesis_translate_off
        if (ZERO_FILL !== 32'h00000000) begin
            // optional debug fill
        end
        // synthesis_translate_on
    end

    // =========================================================================
    // SYNCHRONOUS WRITE
    // =========================================================================
    always @(posedge clk) begin
        if (we) begin
            case (wsize)
                2'b00: begin // byte
                    mem[w_idx] <= wdata[7:0];
                end

                2'b01: begin // halfword
                    mem[w_idx + 0] <= wdata[7:0];
                    mem[w_idx + 1] <= wdata[15:8];
                end

                2'b10: begin // word
                    mem[w_idx + 0] <= wdata[7:0];
                    mem[w_idx + 1] <= wdata[15:8];
                    mem[w_idx + 2] <= wdata[23:16];
                    mem[w_idx + 3] <= wdata[31:24];
                end

                default: begin
                    // reserved
                end
            endcase
        end
    end

    // =========================================================================
    // ASYNCHRONOUS READ
    // =========================================================================
    wire [7:0]  rd_byte = mem[r_idx];
    wire [15:0] rd_half = {mem[r_idx + 1], mem[r_idx]};
    wire [31:0] rd_word = {mem[r_idx + 3], mem[r_idx + 2],
                            mem[r_idx + 1], mem[r_idx]};

    always @* begin
        rdata = 32'h00000000;

        case (rsize)
            2'b00: begin
                rdata = sign_ext ? {{24{rd_byte[7]}}, rd_byte}
                                 : {24'b0, rd_byte};
            end

            2'b01: begin
                rdata = sign_ext ? {{16{rd_half[15]}}, rd_half}
                                 : {16'b0, rd_half};
            end

            2'b10: begin
                rdata = rd_word;
            end

            default: begin
                rdata = 32'h00000000;
            end
        endcase
    end

endmodule

`default_nettype wire