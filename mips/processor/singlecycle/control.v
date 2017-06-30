`include "_const.v"

module control(reg_write, alu_src, alu_op, addr_a, addr_b, addr_in, shamt, imm16, addr26, is_jump, is_branch, instruction);
    input [31:0] instruction;
    output reg [4:0] addr_a, addr_b, addr_in, shamt;
    output [15:0] imm16;
    output [25:0] addr26;
    output reg is_jump;
    output reg is_branch;
    output reg alu_src;  // 0 = data_b, 1 = sign ext imm16
    output reg reg_write;
    output reg [2:0] alu_op;

    wire [5:0] opcode, func;
    wire [4:0] rs, rt, rd, shift_amount;

    // split instruction into wires
    assign opcode = instruction[31:26];
    assign rs = instruction[25:21];
    assign rt = instruction[20:16];
    assign rd = instruction[15:11];
    assign shift_amount = instruction[10:6];
    assign func = instruction[5:0];
    assign imm16 = instruction[15:0];
    assign addr26 = instruction[25:0];

    initial begin
        is_branch = 0;
        is_jump = 0;
        reg_write = 0;
        alu_op = 0;
        addr_a = 0;
        addr_b = 0;
        addr_in = 0;
        alu_src = 0;
        shamt = 0;
    end

    // Doing it the easy way now, will rewrite if in the future it seems useful to do
    always @(instruction) begin
        shamt = 0;
        is_branch = 0;
        is_jump = 0;
        reg_write = 0;
        case (opcode)
            `OPCODE_ADDI: begin
                alu_op = `OP_ADD;
                alu_src = `ALU_SRC_IMM16;
                addr_in = rt;
                addr_a = rs;
                reg_write = 1;
            end
            `OPCODE_ANDI: begin

            end
            `OPCODE_BALMN: begin

            end
            `OPCODE_BALMZ: begin

            end
            `OPCODE_BEQ: begin

            end
            `OPCODE_BEQAL: begin

            end
            `OPCODE_BMN: begin

            end
            `OPCODE_BMZ: begin

            end
            `OPCODE_BNE: begin

            end
            `OPCODE_BNEAL: begin

            end
            `OPCODE_JALM: begin

            end
            `OPCODE_JALPC: begin

            end
            `OPCODE_JM: begin

            end
            `OPCODE_JPC: begin

            end
            `OPCODE_LW: begin

            end
            `OPCODE_ORI: begin

            end
            `OPCODE_SW: begin

            end
            `OPCODE_BALN: begin

            end
            `OPCODE_BALZ: begin

            end
            `OPCODE_BN: begin

            end
            `OPCODE_BZ: begin

            end
            `OPCODE_JAL: begin

            end
            `OPCODE_J: begin

            end

            `OPCODE_RTYPE: begin
                // see below
            end
        endcase
    end

    always @(instruction) if (opcode == `OPCODE_RTYPE) begin
        case (func)
            `FUNC_ADD: begin
                alu_op = `OP_ADD;
                alu_src = `ALU_SRC_DATA_B;
                addr_in = rd;
                addr_a = rs;
                addr_b = rt;
                reg_write = 1;
            end
            `FUNC_AND: begin
                alu_op = `OP_AND;
                alu_src = `ALU_SRC_DATA_B;
                addr_in = rd;
                addr_a = rs;
                addr_b = rt;
                reg_write = 1;
            end
            `FUNC_BALRN: begin

            end
            `FUNC_BALRZ: begin

            end
            `FUNC_BRN: begin

            end
            `FUNC_BRZ: begin

            end
            `FUNC_JALR: begin

            end
            `FUNC_JR: begin

            end
            `FUNC_NOR: begin

            end
            `FUNC_OR: begin

            end
            `FUNC_SLT: begin

            end
            `FUNC_SLL: begin

            end
            `FUNC_SRL: begin

            end
            `FUNC_SUB: begin

            end
        endcase
    end



endmodule
