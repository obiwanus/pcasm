`ifndef _assert_h
`define _assert_h

`define assertEq(signal, value) \
    if ((signal) !== (value)) begin \
        $display("Assertion failed in %m:%3d: %h != %h", `__LINE__, (signal), (value)); \
        error = 1; \
    end

`endif  // assert_h
