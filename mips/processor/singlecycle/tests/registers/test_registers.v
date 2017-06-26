`timescale 1ns/1ns

module test_registers(clk);
    input clk;

    reg error = 0;
    reg write = 0;
    reg [4:0] addr_a = 0, addr_b = 0, addr_in = 0;
    reg [31:0] data_in = 0;
    wire [31:0] data_a, data_b;

    register_file MUT(data_a, data_b, addr_a, addr_b, addr_in, data_in, write, clk);

    initial begin
       $readmemh("tests/registers/reg.dat", MUT.registers);

       // Test fetch
       addr_a = 0;
       addr_b = 0;
       #1;
       if (data_a !== 0 || data_b !== 0) begin
           $display("Zero register fetch failed");
           error = 1;
       end

       @(posedge clk);

       addr_a = 1;
       addr_b = 2;
       #1;
       if (data_a !== 32'h14 || data_b !== 32'h40) begin
           $display("Fetch 1 failed");
           error = 1;
       end

       @(posedge clk);

       addr_a = 6;
       addr_b = 9;
       #1;
       if (data_a !== 32'h32 || data_b !== 32'h28) begin
           $display("Fetch 2 failed");
           error = 1;
       end

       if (error !== 1) $display("===== Register file OK =====");
    end
endmodule
