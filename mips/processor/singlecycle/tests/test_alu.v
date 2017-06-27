`timescale 1ns/1ns
`include "_const.v"

module test_alu;

    reg error = 0;

    reg [31:0] a = 0, b = 0;
    reg [2:0] op = 0;
    wire [31:0] out;
    wire zout;

    alu MUT(out, zout, a, b, op);

    initial begin

        a = 1;
        b = 28;
        op = `OP_ADD;
        #1;
        if (out !== 29 || zout !== 0) begin
            $display("Add failed");
            error = 1;
        end

        a = 1;
        b = 28;
        op = `OP_SUB;
        #1;
        if (out !== -27 || zout !== 0) begin
            $display("Sub failed");
            error = 1;
        end

        a = 32;
        b = 32;
        op = `OP_SUB;
        #1;
        if (out !== 0 || zout !== 1) begin
            $display("Zout on sub failed");
            error = 1;
        end

        a = 32'b01110010;
        b = 32'b10100001;
        op = `OP_OR;
        #1;
        if (out !== 32'b11110011 || zout !== 0) begin
            $display("OR failed");
            error = 1;
        end

        a = 32'b01110010;
        b = 32'b10100001;
        op = `OP_AND;
        #1;
        if (out !== 32'b00100000 || zout !== 0) begin
            $display("AND failed");
            error = 1;
        end

        a = 6;
        b = 2;
        op = `OP_SLT;
        #1;
        if (out !== 0 || zout !== 1) begin
            $display("SLT false failed");
            error = 1;
        end

        a = 23;
        b = 34;
        op = `OP_SLT;
        #1;
        if (out !== 1 || zout !== 0) begin
            $display("SLT true failed");
            error = 1;
        end

        if (error !== 1)
            $display("===== ALU OK =====");
        else
            $display("===== ALU FAIL =====");

    end
endmodule
