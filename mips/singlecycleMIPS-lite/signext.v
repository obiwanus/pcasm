module signext(in1,out1);
input [15:0] in1;
output [31:0] out1;
integer i;
reg out1;
always @(in1)
begin
for (i=31; i>15; i=i-1)
out1[i]=in1[15];
for (i=0; i<16 ; i=i+1)
out1[i]=in1[i];
end
endmodule