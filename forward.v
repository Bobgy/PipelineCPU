module Forward(
    input [31:0] data0,
    input [31:0] data1,
    input bubble,
    input write,
    input same_addr,
    output [31:0] data
);
    assign data = (!bubble && write && same_addr) ? data1 : data0;
endmodule
