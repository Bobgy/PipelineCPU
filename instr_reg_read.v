`include "header.v"
// readRx:
//   00 -> no read
//   01 -> read at EX stage
//   10 -> read at MEM stage
module InstrRegRead(
    input [31:0] I,
    output [1:0] readRs,
    output [1:0] readRt
);
    reg [3:0] read;
    always @* begin
        case(I[`OP])
            `R    : case(I[`FN])
                        `SLL: read <= 2'b00_01;
                        `SRL: read <= 2'b00_01;
                        `SRA: read <= 2'b00_01;
                        default: read <= 2'b01_01;
                    endcase
            `JMP  : read <= 2'b00_00;
            `SW   : read <= 2'b01_10;
            default : read <= 2'b01_00;
        endcase
    end
    assign {readRs, readRt} = read;
endmodule
