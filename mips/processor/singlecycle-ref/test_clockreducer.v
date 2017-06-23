`timescale 1ns/1ns

module system;
    wire clk;
    clkGen clockGenerator(clk);
    divideBy3 clockReducer(clk, slow_clk);

    initial begin
         $dumpfile("clockreducer.vcd");
         $dumpvars(0, clk, slow_clk);
    #150 $finish;
    end
endmodule

module clkGen(clk);
    parameter period = 5;
    output reg clk;

    initial clk = 0;

    always begin
        #period clk = 1;
        #period clk = 0;
    end
endmodule

module divideBy3(inClk, outClk);
    input inClk;
    output reg outClk;
    reg [2:0] clk_count;

    initial begin
        outClk = 0;
        clk_count = 2;
    end

    always @(posedge inClk) if (clk_count == 2) outClk = 1;

    always @(negedge inClk) begin
        outClk = 0;
        if (clk_count == 2)
            clk_count = 0;
        else
            clk_count = clk_count + 1;
    end
endmodule
