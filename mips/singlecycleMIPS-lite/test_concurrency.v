module M;
  reg clock;
  integer x, y, i;

  initial begin
    $dumpfile("concur.vcd");
    $dumpvars(0, M);

    x = 1;                      // 1
    forever  @(negedge clock)   // 2
        if (x == 4)             // 3
        $finish;                // 4
  end

  always @(posedge clock) begin
    x = x + 1;    // 5
  end

  always @(posedge clock) begin
    #1 y = x;        // 6
  end

  initial clock = 0;    // 7
  always
  #2 clock = ~clock;    // 8
endmodule
