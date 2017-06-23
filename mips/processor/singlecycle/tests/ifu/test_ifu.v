module test_ifu;
    wire [31:0] instruction;
    wire [15:0] imm16;
    wire [25:0] addr26;
    wire is_branch, is_jump;
    wire clk;

    instruction_fetch IFU(instruction, imm16, addr26, is_jump, is_branch, clk);

    initial begin
        #5 $readmemb("imem.dat", IFU.imemory.storage.bytes);



        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!




    end
endmodule
