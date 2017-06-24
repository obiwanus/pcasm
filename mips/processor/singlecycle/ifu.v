module instruction_fetch(instruction, imm16, addr26, is_jump, is_branch, clk);
    // Note: see CS-224 lecture 24 7:00
    output [31:0] instruction;
    input [15:0] imm16;
    input [25:0] addr26;
    input is_branch, is_jump;
    input clk;

    reg [29:0] pc;  // even though our addresses are 8 bits (and 6 bits for instructions)
    wire [29:0] pc_new, pc_seq, pc_jump, pc_branch, pc_seq_or_br, imm16_ext;
    wire [31:0] instr_addr;

    rom imemory(instruction, instr_addr);
    mux2_30 jmux(pc_new, pc_jump, pc_seq_or_br, is_jump);
    mux2_30 bmux(pc_seq_or_br, pc_branch, pc_seq, is_branch);
    signext16_30 sext_imm(imm16_ext, imm16);

    assign pc_jump = {pc[29:26], addr26};
    assign pc_seq = pc + 1;
    assign pc_branch = pc_seq + imm16_ext;
    assign instr_addr = {pc, 2'b00};

    // TMP: remove me
    assign imm16 = 0;
    assign addr26 = 0;
    assign is_branch = 0;
    assign is_jump = 0;

    initial begin
        $readmemb("init/imem.dat", imemory.storage.bytes);
        pc = -1;
    end

    always @(negedge clk) begin
        pc = pc_new;
    end

endmodule