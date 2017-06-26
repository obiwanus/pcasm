module alu(out, zout, a, b, op);
    input [31:0] a, b;
    input [2:0] op;
    output reg [31:0] out;
    output reg zout;

    reg [31:0] diff;

    localparam OP_AND = 3'b000;
    localparam OP_OR  = 3'b001;
    localparam OP_ADD = 3'b010;
    localparam OP_SUB = 3'b110;
    localparam OP_SLT = 3'b111;

    always @(a or b or op) begin
        case (op)
            3'b000: out = a & b;
            3'b001: out = a | b;
            3'b010: out = a + b;
            3'b110: out = a + 1 + (~b);
            3'b111: begin
                        diff = a + 1 + (~b);
                        out = diff[31] ? 1 : 0;
                    end
            default: out = 32'bx;
        endcase
        zout = ~(|out);
    end
endmodule
