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
                        // new
                        `ADDU: tp <= 16;
                        `SUBU: tp <= 17;
                        `XOR : tp <= 18;
                        `NOR : tp <= 19;
                        `SLT : tp <= 20;
                        `SLTU: tp <= 21;
                        `SLLV: tp <= 22;
                        `SRLV: tp <= 23;
                        `SRAV: tp <= 24;
                        `JR  : tp <= 25;
                    endcase
            `ADDI : tp <= 8;
            `ANDI : tp <= 9;
            `ORI  : tp <= 10;
            `LW   : tp <= 11;
            `SW   : tp <= 12;
            `BEQ  : tp <= 13;
            `BNE  : tp <= 14;
            `JMP  : tp <= 15;
            //new
            `ADDIU: tp <= 26;
            `XORI : tp <= 27;
            `LUI  : tp <= 28;
            `SLTI : tp <= 29;
            `SLTIU: tp <= 30;
            `JAL  : tp <= 31;
            default : tp <= -1;
        endcase
    end
    wire [15:0] tmp;
    bin2asc b2a0(tp[3:0], tmp[7:0]),
            b2a1({3'b0,tp[4]}, tmp[15:8]);
    assign type = Bubble ? "xx" : tmp;
endmodule
