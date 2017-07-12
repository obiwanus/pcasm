`include "_const.v"

module control(
    input [31:0] instruction,

    output reg reg_write,
    output reg reg_dst,
    output reg write_reg31,
    output reg link,
    output reg alu_src,
    output reg [2:0] alu_op,
    output reg ext_op,
    output reg mem_write,
    output reg mem_to_reg,
    output reg is_jump,
    output reg zero_branch,
    output reg need_zero,
    output reg status_branch,
    output reg need_st_Z,
    output reg [1:0] pc_select
);

    wire [5:0] opcode, func;

    assign opcode = instruction[31:26];
    assign func = instruction[5:0];

    initial begin
        reg_write = 0;
        reg_dst = 0;
        write_reg31 = 0;
        link = 0;
        alu_src = 0;
        alu_op = 3'b0;
        ext_op = 0;
        mem_write = 0;
        mem_to_reg = 0;
        is_jump = 0;
        zero_branch = 0;
        need_zero = 0;
        status_branch = 0;
        need_st_Z = 0;
        pc_select = 2'b0;
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
                is_jump = 1;
            end

            `OPCODE_RTYPE: begin
                // see below
            end
        endcase
    end

    always @(instruction) if (opcode == `OPCODE_RTYPE) begin
        // defaults
        addr_a = rs;
        addr_b = rt;
        addr_in = rd;
        reg_write = 1;
        alu_src = `ALU_SRC_DATA_B;
        shamt = 0;

        case (func)
            `FUNC_ADD: begin
                alu_op = `OP_ADD;
            end
            `FUNC_AND: begin
                alu_op = `OP_AND;
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
                reg_write = 0;
                $display("FUNC_JR not implemented");
            end
            `FUNC_NOR: begin
                alu_op = `OP_NOR;
            end
            `FUNC_OR: begin
                alu_op = `OP_OR;
            end
            `FUNC_SLT: begin
                alu_op = `OP_SLT;
            end
            `FUNC_SLL: begin
                alu_op = `OP_SLL;
                shamt = shift_amount;
                addr_a = rt;
            end
            `FUNC_SRL: begin
                alu_op = `OP_SRL;
                shamt = shift_amount;
                addr_a = rt;
            end
            `FUNC_SUB: begin
                alu_op = `OP_SUB;
            end
            default: begin
                reg_write = 0;
            end
        endcase
    end



endmodule
