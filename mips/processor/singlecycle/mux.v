module mux2_30(out, a, b, select);
    output [29:0] out;
    input [29:0] a, b;
    input select;

    assign out = select ? a : b;
endmodule
