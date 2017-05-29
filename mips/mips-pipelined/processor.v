`timescale 1ns/1ns

module processor;
    wire clk, reg_write;
    wire [4:0] addr_a, addr_b;
    wire [31:0] data_a, data_b, data_in;

    clock_generator clk_gen(clk);
    register_file registers(data_a, data_b, addr_a, addr_b, data_in, reg_write, clk);

    assign reg_write = 0;

    assign addr_a = 5'h1;
    assign addr_b = 5'h2;

endmodule

// A 32-bit register file containing 32 registers
module register_file(data_a, data_b, addr_a, addr_b, data_in, write, clk);
    input [4:0] addr_a, addr_b;
    input [31:0] data_in;
    input write, clk;
    output [31:0] data_a, data_b;

    reg [31:0] registers [0:31];

    assign data_a = registers[addr_a];
    assign data_b = registers[addr_b];

    initial $readmemh("init_reg.dat", registers);

    always @(posedge clk) if (write) registers[addr_a] = data_in;
endmodule

module clock_generator(clk);
    parameter frequency = 20;
    output reg clk;

    initial clk = 0;

    always begin
        #frequency clk = ~clk;
    end
endmodule

module memory(data_out, addr, data_in, write);
    parameter word_size = 32;
    parameter // !!!!!!!!!!!
endmodule
