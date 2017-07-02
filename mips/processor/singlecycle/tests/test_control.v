`timescale 1ns/1ns
`include "_const.v"
`include "_assert.v"

module test_control;

    reg error = 0;

    reg [31:0] instruction;
    wire [4:0] addr_a, addr_b, addr_in, shamt;
    wire [15:0] imm16;
    wire [25:0] addr26;
    wire is_jump, is_branch;
    wire [1:0] alu_src;
    wire [2:0] alu_op;

    control MUT(reg_write, alu_src, alu_op, addr_a, addr_b, addr_in, shamt, imm16, addr26, is_jump, is_branch, instruction);

    initial begin
        // addi    $s0, $zero, 0xFEFE
        instruction = 32'b00100000000100001111111011111110;
        #1;
        `assertEq(addr_a, 5'b0)
        `assertEq(addr_in, 5'b10000)
        `assertEq(imm16, 16'hFEFE)
        `assertEq(is_jump, 0)
        `assertEq(is_branch, 0)
        `assertEq(shamt, 0)
        `assertEq(alu_op, `OP_ADD)
        `assertEq(alu_src, `ALU_SRC_SEXT_IMM16)

        // sll     $s0, $s0, 16
        instruction = 32'b00000000000100001000010000000000;
        #1;
        `assertEq(addr_a, 5'b10000)
        `assertEq(addr_in, 5'b10000)
        `assertEq(is_jump, 0)
        `assertEq(is_branch, 0)
        `assertEq(shamt, 16)
        `assertEq(alu_op, `OP_SLL)

        // add     $t0, $zero, $zero
        instruction = 32'b00000000000000000100000000100000;
        #1;
        `assertEq(addr_a, 5'b0)
        `assertEq(addr_b, 5'b0)
        `assertEq(addr_in, 5'b01000)
        `assertEq(is_jump, 0)
        `assertEq(is_branch, 0)
        `assertEq(shamt, 0)
        `assertEq(alu_op, `OP_ADD)

        // slt     $t1, $t0, $s1
        instruction = 32'b00000001000100010100100000101010;
        #1;
        `assertEq(addr_a, 5'b01000)
        `assertEq(addr_b, 5'b10001)
        `assertEq(addr_in, 5'b01001)
        `assertEq(is_jump, 0)
        `assertEq(is_branch, 0)
        `assertEq(shamt, 0)
        `assertEq(alu_op, `OP_SLT)

        // 000000 10000 10001 01000 00000 100100
        // and     $t0, $s0, $s1
        instruction = 32'b00000010000100010100000000100100;
        #1;
        `assertEq(addr_a, 5'b10000)
        `assertEq(addr_b, 5'b10001)
        `assertEq(addr_in, 5'b01000)
        `assertEq(is_jump, 0)
        `assertEq(is_branch, 0)
        `assertEq(shamt, 0)
        `assertEq(alu_op, `OP_AND)

        // andi    rt, rs, imm     rt = rs & zeroext(imm)
        instruction = 32'b00110010000010010000000011001111;
        #1;
        `assertEq(addr_a, 5'b10000)
        `assertEq(addr_in, 5'b01001)
        `assertEq(is_jump, 0)
        `assertEq(is_branch, 0)
        `assertEq(shamt, 0)
        `assertEq(imm16, 16'b0000000011001111)
        `assertEq(alu_op, `OP_AND)

        // 001101 10000 01001 0000000011000000
        // ori     $t1, $s0, 0xC0
        instruction = 32'b00110110000010010000000011000000;
        #1;
        `assertEq(addr_a, 5'b10000)
        `assertEq(addr_in, 5'b01001)
        `assertEq(is_jump, 0)
        `assertEq(is_branch, 0)
        `assertEq(shamt, 0)
        `assertEq(imm16, 16'b0000000011000000)
        `assertEq(alu_op, `OP_OR)

        // $display("TODO: test control ");

        // // bne     $t1, $zero, loop
        // instruction = 32'b00010101001000001111111111111101;
        // #1;
        // `assertEq(addr_a, 5'b01001)
        // `assertEq(addr_b, 5'b00000)
        // `assertEq(imm16, 16'b1111111111111101)
        // `assertEq(is_jump, 0)
        // `assertEq(is_branch, 1)
        // `assertEq(shamt, 0)

        // // sw      $s0, 0($t0)
        // instruction = 32'b00000000000000000100000000100000;
        // #1;
        // `assertEq(addr_a, 5'b10000)  // value
        // `assertEq(addr_b, 5'b01000)  // address
        // `assertEq(imm16, 16'b0)      // offset
        // `assertEq(is_jump, 0)
        // `assertEq(is_branch, 0)
        // `assertEq(shamt, 0)
        //  // write !== 1  ????????

        // TODO:
        // balrn   0x17    rs, rd          if [z]=0, branch and link to rs, store return in rd (31 by default)
        // balrz   0x16    rs, rd          if [z]=1, ---^---
        // brn     0x15    rs              if [z]=0, branch to rs
        // brz     0x14    rs              if [z]=1, branch to rs
        // jalr    0x09    rs, rd          unconditional jump and link
        // jr      0x08    rs              unconditional jump
        // nor     0x27    rd, rs, rt
        // or      0x25    rd, rs, rt
        // srl     0x02    rd, rt, shamt   rd = rt >> shamt
        // sub     0x22    rd, rs, rt      rd = rs - rt
        // balmn   0x17    rt, imm(rs)     if [z]=0, branches to address in memory and links to rt(31)
        // balmz   0x16    rt, imm(rs)     if [z]=1, ---^---
        // beq     0x04    rs, rt, offset  if rs=rt, branch to offset
        // beqal   0x2C    rs, rt, offset  if rs=rt, branch to offset and link 31
        // bmn     0x15    imm(rs)         if [z]=0, branch to address in memory
        // bmz     0x14    imm(rs)         if [z]=1, branch to address in memory
        // bneal   0x2D    rs, rt, offset  if rs!=rt, branch to offset and link 31
        // jalm    0x13    rt, imm(rs)     jump to address in memory and link to rt(31)
        // jalpc   0x1F    rt, offset      jump to pc-relative address, and link to rt(31)
        // jm      0x12    imm(rs)         jump to address in memory
        // jpc     0x1E    offset          jump to pc-relative address
        // lw      0x23    rt, imm(rs)     load word at rs+imm into rt
        // ori     0x0D    rt, rs, imm     rt = rs | zeroext(imm)
        // baln    0x1B    target26        if [z]=0, branch to target and link 31
        // balz    0x1A    target26        if [z]=1, branch to target and link 31
        // bn      0x19    target26        if [z]=0, branch to target
        // bz      0x18    target26        if [z]=1, branch to target
        // jal     0x03    target26        jump and link 31
        // j       0x02    target26        jump

        // DONE:
        // add     0x20    rd, rs, rt
        // addi    0x08    rt, rs, imm     rt = rs + imm
        // bne     0x05    rs, rt, offset  if rs!=rt, branch to offset
        // slt     0x2a    rd, rs, rt      set rd to (rs < rt)
        // sll     0x00    rd, rt, shamt   rd = rt << shamt
        // sw      0x2B    rt, imm(rs)     store word in rt into memory at rs+imm


        `printResults

    end
endmodule
