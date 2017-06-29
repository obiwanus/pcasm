module mux2(out, a, b, select);
    parameter width = 32;
    output [width-1:0] out;
    input [width-1:0] a, b;
    input select;

    assign out = select ? a : b;
endmodule
