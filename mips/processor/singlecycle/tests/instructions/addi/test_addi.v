`include "_const.v"

module test_addi;
    reg error = 0;
    processor CPU();

    initial begin
        $readmemb("tests/instructions/addi/addi_imem.dat", CPU.IFU.imemory.storage.bytes);

        repeat(4) @(posedge CPU.clk);

        error = (
            CPU.registers.registers[`REG_S0] !== 32'd0 ||
            CPU.registers.registers[`REG_S1] !== 32'd3 ||
            CPU.registers.registers[`REG_T0] !== 32'd255 ||
            CPU.registers.registers[`REG_T1] !== -32'd3 ||
            1 !== 1
        );

        if (error === 0)
            $display("===== instructions: addi OK =====");
        else
            $display("===== instructions: addi FAIL =====");
    end

endmodule
