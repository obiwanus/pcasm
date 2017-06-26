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
        $readmemb("tests/ifu/imem.dat", MUT.imemory.storage.bytes);

        $display("===== Checking IFU ======")

        // Test sequential fetch
        is_branch = 0;
        is_jump = 0;
        addr26 = 26'b111;

        @(posedge clk);
        if (instruction != INSTR_0) begin
            $display("Sequential fetch 1 failed");
            error = 1;
        end
        @(posedge clk);
        if (instruction != INSTR_1) begin
            $display("Sequential fetch 2 failed");
            error = 1;
        end
        @(posedge clk);
        if (instruction != INSTR_2) begin
            $display("Sequential fetch 3 failed");
            error = 1;
        end

        // Test jump
        is_branch = 0;
        is_jump = 1;
        addr26 = 26'h0;  // jump back to instruction 0
        @(posedge clk);
        if (instruction !== INSTR_0) begin
            $display("Jump back to 0 failed");
            error = 1;
        end
        is_jump = 1;
        addr26 = 26'h2;  // jump to instruction 2
        @(posedge clk);
        if (instruction !== INSTR_2) begin
            $display("Jump to instruction 2 failed");
            error = 1;
        end

        // Test branch
        is_jump = 0;
        is_branch = 1;
        imm16 = -2;
        @(posedge clk);
        if (instruction !== INSTR_0) begin
            $display("Branch to instruction 0 failed");
            error = 1;
        end
        is_branch = 0;

        // Wait 2 cycles - pc should be 2
        @(posedge clk);
        @(posedge clk);

        is_branch = 1;
        is_jump = 0;
        imm16 = -1;
        @(posedge clk);
        if (instruction !== INSTR_1) begin
            $display("Branch to instruction 1 failed");
            error = 1;
        end
        is_branch = 0;

        if (error !== 1) $display("===== IFU OK ======");
    end
endmodule
