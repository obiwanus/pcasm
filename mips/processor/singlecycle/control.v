`include "_const.v"

module control(reg_write, alu_src, alu_op, addr_a, addr_b, addr_in, shamt, imm16, addr26, is_jump, is_branch, instruction);
    input [31:0] instruction;
    output reg [4:0] addr_a, addr_b, addr_in, shamt;
    output [15:0] imm16;
    output [25:0] addr26;
    output reg is_jump;
    output reg is_branch;
    output reg [1:0] alu_src;  // 0 = data_b, 1 = sign ext imm16,
                               // 2 = zero ext imm16
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
        alu_src = `ALU_SRC_DATA_B;
        shamt = 0;
    end

    // Doing it the easy way now, will rewrite if in the future it seems useful to do
    always @(instruction) begin
        shamt = 0;
        is_branch = 0;
        is_jump = 0;
        reg_write = 0;
        alu_src = `ALU_SRC_DATA_B;

        case (opcode)
            `OPCODE_ADDI: begin
                alu_op = `OP_ADD;
                alu_src = `ALU_SRC_SEXT_IMM16;
                addr_in = rt;
                addr_a = rs;
                reg_write = 1;
            end
            `OPCODE_ANDI: begin
                alu_op = `OP_AND;
                alu_src = `ALU_SRC_ZEXT_IMM16;
                addr_in = rt;
                addr_a = rs;
                reg_write = 1;
            end
            `OPCODE_BALMN: begin
                $display("OPCODE_BALMN not implemented");
            end
            `OPCODE_BALMZ: begin
                $display("OPCODE_BALMZ not implemented");
            end
            `OPCODE_BEQ: begin
                $display("OPCODE_BEQ not implemented");
            end
            `OPCODE_BEQAL: begin
                $display("OPCODE_BEQAL not implemented");
            end
            `OPCODE_BMN: begin
                $display("OPCODE_BMN not implemented");
            end
            `OPCODE_BMZ: begin
                $display("OPCODE_BMZ not implemented");
            end
            `OPCODE_BNE: begin
                $display("OPCODE_BNE not implemented");
            end
            `OPCODE_BNEAL: begin
                $display("OPCODE_BNEAL not implemented");
            end
            `OPCODE_JALM: begin
                $display("OPCODE_JALM not implemented");
            end
            `OPCODE_JALPC: begin
                $display("OPCODE_JALPC not implemented");
            end
            `OPCODE_JM: begin
                $display("OPCODE_JM not implemented");
            end
            `OPCODE_JPC: begin
                $display("OPCODE_JPC not implemented");
            end
            `OPCODE_LW: begin
                $display("OPCODE_LW not implemented");
            end
            `OPCODE_ORI: begin
                alu_op = `OP_OR;
                alu_src = `ALU_SRC_ZEXT_IMM16;
                addr_in = rt;
                addr_a = rs;
                reg_write = 1;
            end
            `OPCODE_SW: begin
                $display("OPCODE_SW not implemented");
            end
            `OPCODE_BALN: begin
                $display("OPCODE_BALN not implemented");
            end
            `OPCODE_BALZ: begin
                $display("OPCODE_BALZ not implemented");
            end
            `OPCODE_BN: begin
                $display("OPCODE_BN not implemented");
            end
            `OPCODE_BZ: begin
                $display("OPCODE_BZ not implemented");
            end
            `OPCODE_JAL: begin
                $display("OPCODE_JAL not implemented");
            end
            `OPCODE_J: begin
                $display("OPCODE_J not implemented");
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
                $display("FUNC_BALRN not implemented");
            end
            `FUNC_BALRZ: begin
                $display("FUNC_BALRZ not implemented");
            end
            `FUNC_BRN: begin
                $display("FUNC_BRN not implemented");
            end
            `FUNC_BRZ: begin
                $display("FUNC_BRZ not implemented");
            end
            `FUNC_JALR: begin
                $display("FUNC_JALR not implemented");
            end
            `FUNC_JR: begin
                $display("FUNC_JR not implemented");
            end
            `FUNC_NOR: begin
                $display("FUNC_NOR not implemented");
            end
            `FUNC_OR: begin
                $display("FUNC_OR not implemented");
            end
            `FUNC_SLT: begin
                alu_op = `OP_SLT;
                alu_src = `ALU_SRC_DATA_B;
                addr_in = rd;
                addr_a = rs;
                addr_b = rt;
                reg_write = 1;
            end
            `FUNC_SLL: begin
                alu_op = `OP_SLL;
                shamt = shift_amount;
                addr_in = rd;
                addr_a = rt;
                reg_write = 1;
            end
            `FUNC_SRL: begin
                $display("FUNC_SRL not implemented");
            end
            `FUNC_SUB: begin
                $display("FUNC_SUB not implemented");
            end
        endcase
    end



endmodule
