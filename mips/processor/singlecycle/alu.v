`include "_const.v"

module alu(out, zout, a, b, op);
    input [31:0] a, b;
    input [2:0] op;
    output reg [31:0] out;
    output reg zout;

    reg [31:0] diff;

    always @(a or b or op) begin
        case (op)
            `OP_AND: out = a & b;
            `OP_OR:  out = a | b;
            `OP_ADD: out = a + b;
            `OP_SUB: out = a + 1 + (~b);
            `OP_SLT: begin
                        diff = a + 1 + (~b);
                        out = diff[31] ? 1 : 0;
                    end
            default: out = 32'bx;
        endcase
        zout = ~(|out);
    end
endmodule
