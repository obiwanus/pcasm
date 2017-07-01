`include "_assert.v"

module test_ifu(input clk);

    wire [31:0] instruction;
    reg [15:0] imm16 = 0;
    reg [25:0] addr26 = 0;
    reg is_branch = 0, is_jump = 0;
    reg error = 0;

    ifu MUT(instruction, imm16, addr26, is_jump, is_branch, clk);

    localparam INSTR_0 = 32'b11001010000011110011001101010101;
    localparam INSTR_1 = 32'b00000000001100110000111111111111;
    localparam INSTR_2 = 32'b00100000000001000000000000001000;

    initial begin
        $readmemb("tests/ifu/test_imem.dat", MUT.imemory.storage.bytes);

        // Test sequential fetch
        is_branch = 0;
        is_jump = 0;
        addr26 = 26'b111;

        @(posedge clk);
        `assertEq(instruction, INSTR_0)
        @(posedge clk);
        `assertEq(instruction, INSTR_1)
        @(posedge clk);
        `assertEq(instruction, INSTR_2)

        // Test jump
        is_branch = 0;
        is_jump = 1;
        addr26 = 26'h0;  // jump back to instruction 0
        @(posedge clk);
        `assertEq(instruction, INSTR_0)
        is_jump = 1;
        addr26 = 26'h2;  // jump to instruction 2
        @(posedge clk);
        `assertEq(instruction, INSTR_2)

        // Test branch
        is_jump = 0;
        is_branch = 1;
        imm16 = -2;
        @(posedge clk);
        `assertEq(instruction, INSTR_0)
        is_branch = 0;

        // Wait 2 cycles - pc should be 2
        @(posedge clk);
        @(posedge clk);

        is_branch = 1;
        is_jump = 0;
        imm16 = -1;
        @(posedge clk);
        `assertEq(instruction, INSTR_1)
        is_branch = 0;

        `printResults
    end
endmodule
