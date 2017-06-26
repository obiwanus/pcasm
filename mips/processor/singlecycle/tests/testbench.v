module testbench;
    clock_generator clkgen(clk);

    test_ifu IFU(clk);
    test_registers register_file(clk);
endmodule
