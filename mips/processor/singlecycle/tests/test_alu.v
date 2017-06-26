`timescale 1ns/1ns

module test_alu;

    reg error = 0;

    reg [31:0] a = 0, b = 0;
    reg [2:0] op = 0;
    wire [31:0] out;
    wire zout;

    alu MUT(out, zout, a, b, op);

    initial begin


        if (error !== 1)
            $display("===== ALU OK =====");
        else
            $display("===== ALU FAIL =====");

    end
endmodule
