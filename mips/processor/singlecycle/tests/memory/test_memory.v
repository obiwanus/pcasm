`timescale 1ns/1ns

module test_memory(clk);
    input clk;

    reg error = 0;
    reg write = 0;
    reg [31:0] addr_in = 0;
    reg [31:0] data_in = 0;
    wire [31:0] data_out;

    memory MUT(data_out, addr_in, data_in, write, clk);

    initial begin
        $readmemh("tests/memory/test_dmem.dat", MUT.bytes);

        // Test fetch
        addr_in = 0;
        #1;
        if (data_out !== 32'h01000000) begin
            $display("Fetch 1 failed");
            error = 1;
        end
        @(posedge clk);

        addr_in = 4;
        #1;
        if (data_out !== 32'h04030201) begin
            $display("Fetch 2 failed");
            error = 1;
        end
        @(posedge clk);

        // Test write
        addr_in = 8;
        data_in = 32'hF0C0D0E0;
        write = 1;
        @(posedge clk);
        write = 0;
        #1;
        if (data_out !== 32'hF0C0D0E0) begin
            $display("Write 1 failed");
            error = 1;
        end

        // Test unaligned read
        addr_in = 6;
        #1;
        if (data_out != 32'hD0E00403) begin
            $display("Unaligned read 1 failed");
            error = 1;
        end

        if (error !== 1)
            $display("===== Memory OK =====");
        else
            $display("===== Memory FAIL =====");

    end
endmodule
