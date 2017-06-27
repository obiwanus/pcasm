`timescale 1ns/1ns

module test_signext;
    reg error = 0;
    wire [29:0] out;
    reg [15:0] in;
    signext16_30 MUT(out, in);

    initial begin

        in = 16'd23;
        #1;
        if (out !== 30'd23) begin
            $display("Positive sign extension failed");
            error = 1;
        end

        in = -16'd23;
        #1;
        if (out !== -30'd23) begin
            $display("Negative sign extension failed");
            error = 1;
        end

        if (error !== 1)
            $display("===== Sign ext OK =====");
        else
            $display("===== Sign ext FAIL =====");

    end
endmodule
