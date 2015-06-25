`include "header.v"
module InstrRegRead(
    input [31:0] I,
    output [4:0] rs,
    output readRs,
    output [4:0] rt,
    output readRt
);
    wire [5:0] op = I[31:26], func = I[5:0];
    reg [1:0] read;
    always @* begin
        case(op)
            `R    : case(func)
                        `SLL: read <= 2'b01;
                        `SRL: read <= 2'b01;
                        `SRA: read <= 2'b01;
                        default: read <= 2'b11;
                    endcase
            `JMP  : read <= 2'b00;
            `SW   : read <= 2'b11;
            default : read <= 2'b10;
        endcase
    end
    assign rs = I[25:21], rt = I[20:16];
    assign {readRs, readRt} = read;
endmodule
