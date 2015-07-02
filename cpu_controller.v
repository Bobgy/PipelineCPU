`include "header.v"

module CpuController(
    input[31:0] I,
    output[9:0] sig,
    output[3:0] alu
);
    reg[9:0] S;
    reg[3:0] ALU;
    always @* begin
        case(I[`OP])
            `R: begin
                if (I[`FN]==`JR) begin
                    S <= 10'b00000_0000_1; ALU <= `ALU_NOP;
                end else begin
                    S <= 10'b00100_0100_0; ALU <= `ALU_FUNC;
                end
            end
            `LW    : begin S <= 10'b00001_1100_0; ALU <= `ALU_ADD;  end
            `SW    : begin S <= 10'b00001_0010_0; ALU <= `ALU_ADD;  end
            `BEQ   : begin S <= 10'b00000_0001_0; ALU <= `ALU_NOP;  end
            `BNE   : begin S <= 10'b10000_0001_0; ALU <= `ALU_NOP;  end
            `JMP   : begin S <= 10'b00000_0000_1; ALU <= `ALU_NOP;  end
            `ADDI  : begin S <= 10'b00001_0100_0; ALU <= `ALU_ADD;  end
            `ANDI  : begin S <= 10'b01001_0100_0; ALU <= `ALU_AND;  end
            `ORI   : begin S <= 10'b01001_0100_0; ALU <= `ALU_OR;   end
            `ADDIU : begin S <= 10'b01001_0100_0; ALU <= `ALU_ADDU; end
            `XORI  : begin S <= 10'b01001_0100_0; ALU <= `ALU_XOR;  end
            `LUI   : begin S <= 10'b01001_0100_0; ALU <= `ALU_SLL;  end
            `SLTI  : begin S <= 10'b00001_0100_0; ALU <= `ALU_SLT;  end
            `SLTIU : begin S <= 10'b01001_0100_0; ALU <= `ALU_SLTU; end
            `JAL   : begin S <= 10'b00010_0100_1; ALU <= `ALU_NOP;  end
            default: begin S <= 10'b0; ALU <= `ALU_NOP; end
        endcase
    end
    assign sig = S, alu = ALU;
endmodule
