module processor;
    regfile registers(data_a, data_b, addr_a, addr_b, data_in, reg_write, clk);
endmodule

// A 32-bit register file containing 32 registers
module regfile(data_a, data_b, addr_a, addr_b, data_in, write, clk);
    input [4:0] addr_a, addr_b;
    input [31:0] data_in;
    input write, clk;
    output [31:0] data_a, data_b;

    reg [31:0] registers [0:31];

    assign data_a = registers[addr_a];
    assign data_b = registers[addr_b];

    always @(posedge clk) if (write) registers[addr_a] = data_in;
endmodule
