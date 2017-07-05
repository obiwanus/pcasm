`timescale 1ns/1ns
`include "_const.v"
`include "_assert.v"

module test_control;

    reg error = 0;

    reg [31:0] instruction;
    wire [4:0] addr_a, addr_b, addr_in, shamt;
    wire [15:0] imm16;
    wire [25:0] addr26;
    wire is_jump, is_branch, reg_write;
    wire [1:0] alu_src;
    wire [2:0] alu_op;

    control MUT(reg_write, alu_src, alu_op, addr_a, addr_b, addr_in, shamt, imm16, addr26, is_jump, is_branch, instruction);

    initial begin

        // ALU instructions

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

        // 000000 00000 10000 01000 00001 000010
        // srl     $s0, $s0, 16
        instruction = 32'b00000000000100000100000001000010;
        #1;
        `assertEq(addr_a, 5'b10000)
        `assertEq(addr_in, 5'b01000)
        `assertEq(is_jump, 0)
        `assertEq(is_branch, 0)
        `assertEq(shamt, 1)
        `assertEq(alu_op, `OP_SRL)

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

        // 000000 10000 10001 01000 00000 100010
        // sub     $t0, $s0, $s1
        instruction = 32'b00000010000100010100000000100010;
        #1;
        `assertEq(addr_a, 5'b10000)
        `assertEq(addr_b, 5'b10001)
        `assertEq(addr_in, 5'b01000)
        `assertEq(is_jump, 0)
        `assertEq(is_branch, 0)
        `assertEq(shamt, 0)
        `assertEq(alu_op, `OP_SUB)

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

        // 000000 10000 10001 01000 00000 100101
        // or     $t0, $s0, $s1
        instruction = 32'b00000010000100010100000000100101;
        #1;
        `assertEq(addr_a, 5'b10000)
        `assertEq(addr_b, 5'b10001)
        `assertEq(addr_in, 5'b01000)
        `assertEq(is_jump, 0)
        `assertEq(is_branch, 0)
        `assertEq(shamt, 0)
        `assertEq(alu_op, `OP_OR)

        // 000000 10000 10001 01000 00000 100111
        // nor    $t0, $s0, $s1
        instruction = 32'b00000010000100010100000000100111;
        #1;
        `assertEq(addr_a, 5'b10000)
        `assertEq(addr_b, 5'b10001)
        `assertEq(addr_in, 5'b01000)
        `assertEq(is_jump, 0)
        `assertEq(is_branch, 0)
        `assertEq(shamt, 0)
        `assertEq(alu_op, `OP_NOR)


        // JUMPS

        // 000010 00000000000000000000000100
        // j target26
        instruction = 32'b00001000000000000000000000000100;
        #1;
        `assertEq(addr26, 26'b00000000000000000000000100)
        `assertEq(is_jump, 1)
        `assertEq(is_branch, 0)
        `assertEq(shamt, 0)

        // 000000 11111 00000 00000 00000 001000
        // jr $ra
        // TODO:
        // instruction = 32'b00000011111000000000000000001000;
        // #1;
        // `assertEq(addr_a, 5'b11111)
        // `assertEq(addr_a, 5'b11111)
        // `assertEq(is_jump, 1)
        // `assertEq(is_branch, 0)
        // `assertEq(shamt, 0)
        // `assertEq(reg_write, 0)

        // 000101 01010 01011 1111111111111100
        // bne     $t2, $t3, loop
        instruction = 32'b00010101010010111111111111111100;
        #1;
        `assertEq(addr_a, 5'b01010)
        `assertEq(addr_b, 5'b01011)
        `assertEq(imm16, 16'b1111111111111100)
        `assertEq(is_jump, 0)
        `assertEq(shamt, 0)
        `assertEq(alu_op, `OP_SUB)

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
        // baln    0x1B    target26        if [z]=0, branch to target and link 31
        // balz    0x1A    target26        if [z]=1, branch to target and link 31
        // bn      0x19    target26        if [z]=0, branch to target
        // bz      0x18    target26        if [z]=1, branch to target
        // jal     0x03    target26        jump and link 31


        `printResults

    end
endmodule
