`timescale 1ns/1ns

module processor;
    wire clk, reg_write;

    // memory wires
    wire [4:0] addr_a, addr_b;
    wire [7:0] mem_addr, instr_addr;
    wire [31:0] data_a, data_b, reg_data_in;
    wire [31:0] instruction, mem_data;

    // alu wires
    wire [31:0] alu_out, alu_in1, alu_in2;
    wire [2:0] alu_op;
    wire alu_zout;

    reg [31:0] pc;  // even though we use only first 8 bits

    clock_generator clk_gen(clk);

    register_file registers(data_a, data_b, addr_a, addr_b, reg_data_in, reg_write, clk);
    memory dmemory(mem_data, mem_addr, , , clk);
    rom imemory(instruction, instr_addr);

    alu ALU(alu_out, alu_zout, alu_in1, alu_in2, alu_op);

    assign alu_in1 = data_a;    // first input on alu is always from register

    initial begin
        $readmemh("init_reg.dat", registers.registers);
        $readmemb("init_imem.dat", imemory.storage.cells);
        $readmemh("init_dmem.dat", dmemory.cells);
    end

endmodule

module instruction_decoder(instruction, opcode, rs, rt, rd, shamt, func, imm16, addr26);
    input [31:0] instruction;
    output [5:0] opcode, func;
    output [4:0] rs, rt, rd, shamt;
    output [15:0] imm16;
    output [25:0] addr26;

    assign opcode = instruction[31:26];
    assign rs = instruction[25:21];
    assign rt = instruction[20:16];
    assign rd = instruction[15:11];
    assign shamt = instruction[10:6];
    assign func = instruction[5:0];
endmodule

module alu(out, zout, a, b, op);
    input [31:0] a, b;
    input [2:0] op;
    output reg [31:0] out;
    output reg zout;

    reg [31:0] diff;

    always @(a or b or op) begin
        case (op)
            3'b000: out = a & b;
            3'b001: out = a | b;
            3'b010: out = a + b;
            3'b110: out = a + 1 + (~b);  // subtract
            3'b111: begin                // set less than
                        diff = a + 1 + (~b);
                        out = diff[31] ? 1 : 0;
                    end
            default: out = 32'bx;
        endcase
        zout = ~(|out);
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

    always @(posedge clk) if (write && addr_a) registers[addr_a] = data_in;
endmodule

module clock_generator(clk);
    parameter frequency = 10;
    output reg clk;

    initial clk = 0;

    always begin
        #frequency clk = ~clk;
    end
endmodule

// Memory (256 x 32bit cells) address is 8 bits, word is 32 bits
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
