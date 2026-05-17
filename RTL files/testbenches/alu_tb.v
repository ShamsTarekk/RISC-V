`timescale 1ns / 1ps

module alu_tb();

    reg [31:0] a, b;
    reg [3:0]  select;

    wire [31:0] result;
    wire zero_flag;

    alu uut (
        .a(a), 
        .b(b), 
        .select(select), 
        .result(result), 
        .zero_flag(zero_flag)
    );

    reg [100:0] op_name;

    task decode_op;
    begin
        case (select)
            4'b0000: op_name = "ADD";
            4'b0001: op_name = "SUB";
            4'b0010: op_name = "SLL";
            4'b0110: op_name = "SRL";
            4'b0111: op_name = "SRA";
            4'b0011: op_name = "SLT";
            4'b0100: op_name = "SLTU";
            4'b0101: op_name = "XOR";
            4'b1000: op_name = "OR";
            4'b1001: op_name = "AND";
            default: op_name = "DEFAULT";
        endcase
    end
    endtask
task check_alu(input [31:0] expected_res, input expected_zero);
    begin
        #10;
        decode_op();

        if (result !== expected_res || zero_flag !== expected_zero) begin
            $display("\n❌ ERROR | OP=%s | select=%b", op_name, select);
          
            $display("a = %h (%b)", a, a);
            $display("b = %h (%b)", b, b);

            $display("EXPECTED : %h (%b) | zero=%b",
                     expected_res, expected_res, expected_zero);

            $display("GOT      : %h (%b) | zero=%b\n",
                     result, result, zero_flag);

        end else begin
            $display("\n✔ PASS | OP=%s | select=%b", op_name, select);
           
            $display("a = %h (%b)", a, a);
            $display("b = %h (%b)", b, b);

            $display("RESULT   : %h (%b)", result, result);
            $display("ZERO     : %b\n", zero_flag);
        end
    end
    endtask

    initial begin
        $dumpfile("simulation.vcd");
        $dumpvars(0, alu_tb);

        $display("Starting ALU Phase 2 Testing...\n");

        // ADD
        select = 4'b0000;
        a = 10; b = 5; check_alu(15, 0);

        a = 32'hFFFFFFFF; b = 1; check_alu(0, 1);

        a = 32'h7FFFFFFF; b = 1; check_alu(32'h80000000, 0);

        // SUB
        select = 4'b0001;
        a = 20; b = 20; check_alu(0, 1);

        a = 10; b = 15; check_alu(32'hFFFFFFFB, 0);

        // SHIFTS
        a = 32'h80000001; b = 1;

        select = 4'b0010; check_alu(32'h00000002, 0);
        select = 4'b0110; check_alu(32'h40000000, 0);
        select = 4'b0111; check_alu(32'hC0000000, 0);

        // COMPARE
        a = 32'hFFFFFFFF; b = 1;

        select = 4'b0011; check_alu(1, 0);
        select = 4'b0100; check_alu(0, 1);

        // LOGIC
        a = 32'hAAAA_AAAA; b = 32'h5555_5555;

        select = 4'b0101; check_alu(32'hFFFF_FFFF, 0);
        select = 4'b1000; check_alu(32'hFFFF_FFFF, 0);
        select = 4'b1001; check_alu(32'h0, 1);

        // DEFAULT
        select = 4'b1010;
        a = 100; b = 50; check_alu(150, 0);

        $display("ALU Testing Complete.");
        $finish;
    end

endmodule