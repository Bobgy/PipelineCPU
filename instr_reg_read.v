`include "header.v"
module InstrRegRead(
    input [31:0] I,
    output [4:0] rs,
    output readRs,
    output [4:0] rt,
    output readRt
);
    wire [1:0] tp;
    InstrType instrType(I, tp);
    assign rs = I[25:21], rt = I[20:16];
    assign readRs = tp != `J_TYPE, readRt = tp == `R_TYPE;
endmodule
