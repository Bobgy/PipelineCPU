`include "header.v"
module ParseType(
    input [31:0] I,
    input Bubble,
    output [15:0] type
);
    wire [5:0] op = I[31:26], func = I[5:0];
    reg [4:0] tp;
    always @* begin
        case(op)
            `R    : case(func)
                        `ADD : tp <= 1;
                        `SUB : tp <= 2;
                        `AND : tp <= 3;
                        `OR  : tp <= 4;
                        `SLL : tp <= 5;
                        `SRL : tp <= 6;
                        `SRA : tp <= 7;
                    endcase
            `ADDI : tp <= 8;
            `ANDI : tp <= 9;
            `ORI  : tp <= 10;
            `LW   : tp <= 11;
            `SW   : tp <= 12;
            `BEQ  : tp <= 13;
            `BNE  : tp <= 14;
            `JMP  : tp <= 15;
            default : tp <= -1;
        endcase
    end
    wire [15:0] tmp;
    bin2asc b2a0(tp[3:0], tmp[7:0]),
            b2a1({3'b0,tp[4]}, tmp[15:8]);
    assign type = Bubble ? "xx" : tmp;
endmodule
