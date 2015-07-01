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
            `R    : if (I[`FN]==`SLL || I[`FN]==`SRL || I[`FN]==`SRA) begin
                        read <= {`READ_NOTHING, `READ_AT_EX};
                    end else if (I[`FN]==`JR) begin
                        read <= {`READ_AT_ID, `READ_NOTHING};
                    end else read <= {`READ_AT_EX, `READ_AT_EX};
            `JMP  : read <= {`READ_NOTHING, `READ_NOTHING};
            `SW   : read <= {`READ_AT_EX, `READ_AT_MEM};
            `BEQ  : read <= {`READ_AT_ID, `READ_AT_ID};
            `BNE  : read <= {`READ_AT_ID, `READ_AT_ID};
            `LUI  : read <= {`READ_NOTHING, `READ_NOTHING};
            `JAL  : read <= {`READ_NOTHING, `READ_NOTHING};
            default : read <= {`READ_AT_EX, `READ_NOTHING};
        endcase
    end
    assign {readRs, readRt} = read;
endmodule
