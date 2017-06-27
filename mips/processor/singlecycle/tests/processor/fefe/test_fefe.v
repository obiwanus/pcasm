/*
* Tests the program 1_fefe.mips, which
* puts 0xFEFE in the first 64 bytes in memory
*/

module test_fefe;  // not covfefe
    reg error = 0;
    processor CPU();

    initial begin
        $readmemb("tests/processor/fefe/test_fefe_imem.dat", CPU.IFU.imemory.storage.bytes);
        $readmemh("tests/processor/fefe/test_fefe_dmem.dat", CPU.dmemory.bytes);

        repeat(19) @(posedge CPU.clk);

        error = (
            CPU.dmemory.bytes[0] !== 8'hFE ||
            CPU.dmemory.bytes[1] !== 8'hFE ||
            CPU.dmemory.bytes[2] !== 8'hFE ||
            CPU.dmemory.bytes[3] !== 8'hFE
        );

        if (error !== 1)
            $display("===== fefe OK so far =====");
        else
            $display("===== fefe FAIL =====");
    end

endmodule
