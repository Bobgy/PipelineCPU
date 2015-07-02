`include "header.v"
module ParseType(
    input [31:0] I,
    input Bubble,
    output [15:0] type
);
    wire [5:0] op = I[31:26], func = I[5:0];
    reg [7:0] tp;
    always @* begin
        case(op)
            `R    : case(func)
                        `ADD : tp <= 8'h01;
                        `SUB : tp <= 8'h02;
                        `AND : tp <= 8'h03;
                        `OR  : tp <= 8'h04;
                        `SLL : tp <= 8'h05;
                        `SRL : tp <= 8'h06;
                        `SRA : tp <= 8'h07;
                        // new
                        `ADDU: tp <= 8'h10;
                        `SUBU: tp <= 8'h11;
                        `XOR : tp <= 8'h12;
                        `NOR : tp <= 8'h13;
                        `SLT : tp <= 8'h14;
                        `SLTU: tp <= 8'h15;
                        `SLLV: tp <= 8'h16;
                        `SRLV: tp <= 8'h17;
                        `SRAV: tp <= 8'h18;
                        `JR  : tp <= 8'h19;
                        default: tp <= -1;
                    endcase
            `ADDI : tp <= 8'h08;
            `ANDI : tp <= 8'h09;
            `ORI  : tp <= 8'h0A;
            `LW   : tp <= 8'h0B;
            `SW   : tp <= 8'h0C;
            `BEQ  : tp <= 8'h0D;
            `BNE  : tp <= 8'h0E;
            `JMP  : tp <= 8'h0F;
            //new
            `ADDIU: tp <= 8'h1A;
            `XORI : tp <= 8'h1B;
            `LUI  : tp <= 8'h1C;
            `SLTI : tp <= 8'h1D;
            `SLTIU: tp <= 8'h1E;
            `JAL  : tp <= 8'h1F;
            default : tp <= -1;
        endcase
    end
    wire [15:0] tmp;
    bin2asc b2a0(tp[3:0], tmp[7:0]),
            b2a1(tp[7:4], tmp[15:8]);
    assign type = Bubble ? "xx" : tmp;
endmodule
