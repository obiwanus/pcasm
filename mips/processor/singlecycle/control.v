module control(alu_op, addr_a, addr_b, addr_in, shamt, imm16, addr26, is_jump, is_branch, instruction);
    input [31:0] instruction;
    output [4:0] addr_a, addr_b, addr_in, shamt;
    output [15:0] imm16;
    output [25:0] addr26;
    output is_jump;
    output is_branch;
    output [2:0] alu_op;

    wire [5:0] opcode, func;
    wire [4:0] rs, rt, rd;

    // split instruction into wires
    assign opcode = instruction[31:26];
    assign rs = instruction[25:21];
    assign rt = instruction[20:16];
    assign rd = instruction[15:11];
    assign shamt = instruction[10:6];
    assign func = instruction[5:0];
    assign imm16 = instruction[15:0];
    assign addr26 = instruction[25:0];



endmodule
