module alu32(sum,a,b,zout,gin);
output [31:0] sum;
input [31:0] a,b;
input [2:0] gin;
reg [31:0] sum;
reg [31:0] less;
output zout;
reg zout;
always @(a or b or gin)
begin
	case(gin)
	3'b010: sum=a+b; 
	3'b110: sum=a+1+(~b);
	3'b111: begin less=a+1+(~b);
			if (less[31]) sum=1;
			else sum=0;
		  end
	3'b000: sum=a & b;
	3'b001: sum=a|b;
	default: sum=31'bx;
	endcase
zout=~(|sum);
end
endmodule
