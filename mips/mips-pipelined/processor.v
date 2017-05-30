`timescale 1ns/1ns

module processor;
    wire clk, reg_write;
    wire [4:0] addr_a, addr_b;
    wire [7:0] mem_addr, instr_addr;
    wire [31:0] data_a, data_b, reg_data_in;
    wire [31:0] instruction, mem_data;

    clock_generator clk_gen(clk);
    register_file registers(data_a, data_b, addr_a, addr_b, reg_data_in, reg_write, clk);
    memory dmemory(mem_data, mem_addr, , , clk);
    rom imemory(instruction, instr_addr);

    assign reg_write = 1;
    assign addr_a = 5'b0;
    assign reg_data_in = 32'b111000;
    assign addr_b = 5'h2;

    initial begin
        $readmemh("init_reg.dat", registers.registers);
        $readmemh("init_imem.dat", imemory.storage.cells);
        $readmemh("init_dmem.dat", dmemory.cells);
    end

endmodule

// A 32-bit register file containing 32 registers
module register_file(data_a, data_b, addr_a, addr_b, data_in, write, clk);
    input write, clk;
    input [4:0] addr_a, addr_b;
    input [31:0] data_in;
    output [31:0] data_a, data_b;

    reg [31:0] registers [0:31];

    assign data_a = registers[addr_a];
    assign data_b = registers[addr_b];

    initial registers[5'b0] = 32'b0;  // hard-wired zero register

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

// An 8-bit word addressable memory (256 x 32bit cells)
module memory(data_out, addr, data_in, write, clk);
    input write, clk;
    input [7:0] addr;
    input [31:0] data_in;
    output [31:0] data_out;

    reg [31:0] cells [0:255];

    assign data_out = cells[addr];

    always @(posedge clk) if (write) cells[addr] = data_in;
endmodule

module rom(data_out, addr);
    input [7:0] addr;
    output [31:0] data_out;

    memory storage(data_out, addr, , , );  // acts as a combinational circuit
endmodule
