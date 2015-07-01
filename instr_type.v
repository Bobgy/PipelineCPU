`include "header.v"
module InstrType(
    input [31:0] I,
    output [1:0] type
);
    wire [5:0] op = I[31:26];
    reg [1:0] tp;
    always @* begin
        case(op)
            `R    : tp <= `R_TYPE;
            `JMP  : tp <= `J_TYPE;
            `JAL  : tp <= `J_TYPE;
            default : tp <= `I_TYPE;
        endcase
    end
    assign type = tp;
endmodule
