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
        $readmemh("init/reg.dat", registers.registers);
        $readmemh("init/dmem.dat", dmemory.bytes);
    end

endmodule
