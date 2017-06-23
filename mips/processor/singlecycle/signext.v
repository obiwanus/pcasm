module signext16_30(out, in);
    output [29:0] out;
    input [15:0] in;
    wire [13:0] sign14;
    wire s;
    assign s = in[15];
    assign sign14 = {s, s, s, s, s, s, s, s, s, s, s, s, s, s};
    assign out = {sign14, in};
endmodule
