`timescale 1ns/1ns

module processor;
    wire clk, reg_write;

    // memory wires
    wire [4:0] addr_a, addr_b, addr_in;
    wire [7:0] mem_addr;
    wire [31:0] data_a, data_b, reg_data_in;
    wire [31:0] instruction, mem_data;

    // alu wires
    wire [31:0] alu_out, alu_in1, alu_in2;
    wire [2:0] alu_op;
    wire alu_zout;

    wire [4:0] shamt;
    wire [15:0] imm16;
    wire [25:0] addr26;

    // control wires
    wire is_jump;

    // modules
    clock_generator clk_gen(clk);
    register_file registers(data_a, data_b, addr_a, addr_b, addr_in, reg_data_in, reg_write, clk);
    memory dmemory(mem_data, mem_addr, , , clk);  // TODO: add missing wires
    control ctrl(addr_a, addr_b, addr_in, shamt, imm16, addr26, is_jump, is_branch, instruction);
    alu ALU(alu_out, alu_zout, alu_in1, alu_in2, alu_op);
    instruction_fetch IFU(instruction, imm16, addr26, is_jump, is_branch, clk);

    // assignments
    assign alu_in1 = data_a;    // first input on alu is always from register

    // procedural blocks
    initial begin
        $readmemh("init_reg.dat", registers.registers);
        $readmemh("init_dmem.dat", dmemory.bytes);
    end

endmodule

module instruction_fetch(instruction, imm16, addr26, is_jump, is_branch, clk);
    // Note: see CS-224 lecture 24 7:00
    output [31:0] instruction;
    input [15:0] imm16;
    input [25:0] addr26;
    input is_branch, is_jump;
    input clk;

    reg [29:0] pc;  // even though our addresses are 8 bits (and 6 bits for instructions)
    wire [29:0] pc_new, pc_seq, pc_jump, pc_branch, pc_seq_or_br, imm16_ext;
    wire [31:0] instr_addr;

    rom imemory(instruction, instr_addr);
    mux2_30 jmux(pc_new, pc_jump, pc_seq_or_br, is_jump);
    mux2_30 bmux(pc_seq_or_br, pc_branch, pc_seq, is_branch);
    signext16_30 sext_imm(imm16_ext, imm16);

    assign pc_jump = {pc[29:26], addr26};
    assign pc_seq = pc + 1;
    assign pc_branch = pc_seq + imm16_ext;
    assign instr_addr = {pc, 2'b00};

    // TMP: remove me
    assign imm16 = 0;
    assign addr26 = 0;
    assign is_branch = 0;
    assign is_jump = 0;

    initial begin
        $readmemb("init_imem.dat", imemory.storage.bytes);
        pc = 0;
    end

    always @(negedge clk) begin
        pc = pc_new;
    end

endmodule

module signext16_30(out, in);
    output [29:0] out;
    input [15:0] in;
    wire [13:0] sign14;
    wire s;
    assign s = in[15];
    assign sign14 = {s, s, s, s, s, s, s, s, s, s, s, s, s, s};
    assign out = {sign14, in};
endmodule

module mux2_30(out, a, b, select);
    output [29:0] out;
    input [29:0] a, b;
    input select;

    assign out = select ? a : b;
endmodule

module control(addr_a, addr_b, addr_in, shamt, imm16, addr26, is_jump, is_branch, instruction);
    input [31:0] instruction;
    output [4:0] addr_a, addr_b, addr_in, shamt;
    output [15:0] imm16;
    output [25:0] addr26;
    output is_jump;
    output is_branch;

    wire [5:0] opcode, func;
    wire [4:0] rs, rt, rd;

    // split instruction into wires
    assign opcode = instruction[31:26];
    assign rs = instruction[25:21];
    assign rt = instruction[20:16];
    assign rd = instruction[15:11];
    assign shamt = instruction[10:6];
    assign func = instruction[5:0];
    assign imm16 = instruction[15:0];
    assign addr26 = instruction[25:0];



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

// TODO: this should probably be add 1!
module add4(out, in);
    output [31:0] out;
    input [31:0] in;

    assign out = in + 4;
endmodule

// A 32-bit register file containing 32 registers
module register_file(data_a, data_b, addr_a, addr_b, addr_in, data_in, write, clk);
    input write, clk;
    input [4:0] addr_a, addr_b, addr_in;
    input [31:0] data_in;
    output [31:0] data_a, data_b;

    reg [31:0] registers [0:31];

    assign data_a = registers[addr_a];
    assign data_b = registers[addr_b];

    initial registers[5'b0] = 32'b0;  // hard-wired zero register

    always @(posedge clk) if (write && addr_a) registers[addr_in] = data_in;
endmodule

module clock_generator(clk);
    parameter frequency = 10;
    output reg clk;

    initial clk = 0;

    always begin
        #frequency clk = ~clk;
    end
endmodule

// Memory (256 x 4 x 8-bit bytes) address is 32 bits (used only 10), word is 32 bits
module memory(data_out, addr_in, data_in, write, clk);
    input write, clk;
    input [31:0] addr_in;
    input [31:0] data_in;
    output [31:0] data_out;

    reg [7:0] bytes [0:255*4];

    wire [9:0] addr;
    assign addr = addr_in[9:0];  // we use only 10 bits of address

    // Little endian
    assign data_out = {bytes[addr+3], bytes[addr+2], bytes[addr+1], bytes[addr]};

    always @(posedge clk) if (write) begin
        bytes[addr]   = data_in[7:0];
        bytes[addr+1] = data_in[15:8];
        bytes[addr+2] = data_in[23:16];
        bytes[addr+3] = data_in[31:24];
    end
endmodule

// Read-only memory
module rom(data_out, addr);
    input [31:0] addr;
    output [31:0] data_out;

    memory storage(data_out, addr, , , );  // acts as a combinational circuit
endmodule
