`include "header.v"
module ParseType(
    input [31:0] I,
    output [15:0] type
);
    wire [5:0] op = I[31:26];
    reg [4:0] tp;
    always @* begin
        case(op)
            `R    : tp <= 0;
            `LW   : tp <= 1;
            `SW   : tp <= 2;
            `BEQ  : tp <= 3;
            `BNE  : tp <= 4;
            `JMP  : tp <= 5;
            `ADDI : tp <= 6;
            `ANDI : tp <= 7;
            `ORI  : tp <= 8;
            default : tp <= -1;
        endcase
    end
    bin2asc b2a0(tp[3:0], type[7:0]),
            b2a1({3'b0,tp[4]}, type[15:8]);
endmodule
