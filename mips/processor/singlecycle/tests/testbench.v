/*
* Main testbench, which includes all individual module testbenches
*/

module testbench;

    clock_generator clkgen(clk);

    // Component tests
    test_ifu IFU(clk);
    test_registers register_file(clk);
    test_memory memory(clk);
    test_alu alu();
    test_signext signext();
    test_control control();

    // Processor tests
    test_fefe fefe();

    // Instruction tests
    test_addi addi();

endmodule
