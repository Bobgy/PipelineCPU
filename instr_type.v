`include "header.v"
module InstrType(
    input [31:0] I,
    output [1:0] type
);
    reg [1:0] tp;
    always @* begin
        case(I[`OP])
            `R    : tp <= `R_TYPE;
            `JMP  : tp <= `J_TYPE;
            `JAL  : tp <= `J_TYPE;
            default : tp <= `I_TYPE;
        endcase
    end
    assign type = tp;
endmodule
