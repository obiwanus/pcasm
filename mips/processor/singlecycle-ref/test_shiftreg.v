`timescale 1ns/1ns

module System;
    wire clk, data_bit;
    ClkGen clockGenerator(clk);
    TestGenerator test(data_bit, clk);

    wire bit_out;
    wire[31:0] count;

    ShiftAndCount shifter(data_bit, bit_out, count, clk);

    initial begin
         $dumpfile("shiftandcount.vcd");
         $dumpvars(0, System);

    #150 $finish;
    end
endmodule

module ClkGen(clk);
    parameter period = 5;
    output reg clk;

    initial clk = 0;

    always
        #period clk = ~clk;
endmodule

module TestGenerator(data_bit, clk);
    output reg data_bit;
    input clk;

    reg[31:0] storage;

    initial begin
        storage = 'hF0A4;
    end

    always @(posedge clk) begin
        data_bit = storage[0];
        storage = storage >> 1;
    end
endmodule

module ShiftAndCount(data_in, bit_out, count, clk);
    parameter depth = 8;

    input data_in, clk;
    output reg bit_out;
    output reg[31:0] count;

    reg[depth-1:0] storage;

    initial begin
        bit_out = 0;
        count = 0;
        storage = 0;
    end

    always @(posedge clk) begin
        if (data_in == 1) count = count + 1;
        bit_out = storage[7];
        storage = storage << 1;
        storage[0] = data_in;
    end

endmodule
