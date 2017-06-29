`timescale 1ns/1ns

module test_signext;
    reg error = 0;
    wire [29:0] out30;
    wire [31:0] out32;
    reg [15:0] in;
    signext16_30 MUT1(out30, in);
    signext16_32 MUT2(out32, in);

    initial begin

        in = 16'd23;
        #1;
        if (out30 !== 30'd23) begin
            $display("Positive sign extension 30 failed");
            error = 1;
        end
        if (out32 !== 32'd23) begin
            $display("Positive sign extension 32 failed");
            error = 1;
        end

        in = -16'd23;
        #1;
        if (out30 !== -30'd23) begin
            $display("Negative sign extension 30 failed");
            error = 1;
        end
        if (out32 !== -32'd23) begin
            $display("Negative sign extension 32 failed");
            error = 1;
        end

        if (error !== 1)
            $display("===== Sign ext OK =====");
        else
            $display("===== Sign ext FAIL =====");

    end
endmodule
