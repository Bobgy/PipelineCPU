`include "header.v"

module CpuController(
    input[31:0] I,
    output[9:0] sig,
    output[3:0] alu
);
    reg[11:0] S;
    reg[3:0] ALU;
    always @* begin
        case(I[`OP])
            `R: begin
                if (I[`FN]==`JR) begin
                    S <= 9'b0000_0000_1; ALU <= `ALU_NOP;
                end else begin
                    S <= 9'b0010_0100_0; ALU <= `ALU_FUNC;
                end
            end
            `LW    : S <= 9'b00001_1100_0; ALU <= `ALU_ADD;
            `SW    : S <= 9'b00001_0010_0; ALU <= `ALU_ADD;
            `BEQ   : S <= 9'b00000_0001_0; ALU <= `ALU_NOP;
            `BNE   : S <= 9'b10000_0001_0; ALU <= `ALU_NOP;
            `JMP   : S <= 9'b00000_0000_1; ALU <= `ALU_NOP;
            `ADDI  : S <= 9'b00001_0100_0; ALU <= `ALU_ADD;
            `ANDI  : S <= 9'b01001_0100_0; ALU <= `ALU_AND;
            `ORI   : S <= 9'b01001_0100_0; ALU <= `ALU_OR;
            `ADDIU : S <= 9'b01001_0100_0; ALU <= `ALU_ADDU;
            `XORI  : S <= 9'b01001_0100_0; ALU <= `ALU_XOR;
            `LUI   : S <= 9'b01001_0000_0; ALU <= `ALU_SLL;
            `SLTI  : S <= 9'b00001_0100_0; ALU <= `ALU_SLT;
            `SLTIU : S <= 9'b01001_0100_0; ALU <= `ALU_SLTU;
            `JAL   : S <= 9'b00010_0100_1; ALU <= `ALU_NOP;
            default: sig <= 9'b0;
        endcase
    end
    assign sig = S;

endmodule
