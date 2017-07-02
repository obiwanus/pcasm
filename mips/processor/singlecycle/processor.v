module processor;
    wire clk;
    wire [4:0] addr_a, addr_b, addr_in;
    wire [31:0] mem_addr;
    wire [31:0] data_a, data_b, reg_data_in, sext_imm16, zext_imm16;
    wire [31:0] instruction, mem_data;

    // alu wires
    wire [31:0] alu_out, alu_in1, alu_in2;
    wire [2:0] alu_op;
    wire [1:0] alu_src;
    wire alu_zout;

    wire [4:0] shamt;
    wire [15:0] imm16;
    wire [25:0] addr26;

    // control wires
    wire is_jump, is_branch, reg_write, mem_write;

    clock_generator clk_gen(clk);
    register_file registers(data_a, data_b, addr_a, addr_b, addr_in, reg_data_in, reg_write, clk);
    memory dmemory(mem_data, mem_addr, , , clk);  // TODO: add missing wires
    control ctrl(reg_write, alu_src, alu_op, addr_a, addr_b, addr_in, shamt, imm16, addr26, is_jump, is_branch, instruction);
    alu ALU(alu_out, alu_zout, alu_in1, alu_in2, alu_op, shamt);
    ifu IFU(instruction, imm16, addr26, is_jump, is_branch, clk);

    assign reg_data_in = alu_out;
    assign alu_in1 = data_a;    // first input on alu is always from register
    mux4 alu_src_select(alu_in2, data_b, sext_imm16, zext_imm16, , alu_src);
    signext16_32 sext_imm(sext_imm16, imm16);
    zeroext16_32 zext_imm(zext_imm16, imm16);

    initial begin
        $readmemb("init/imem.dat", IFU.imemory.storage.bytes);
        $readmemh("init/reg.dat", registers.registers);
        $readmemh("init/dmem.dat", dmemory.bytes);
    end

endmodule
