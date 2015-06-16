`include "header.v"

module CpuController(
    input[5:0] op,
    output[11:0] sig
);

    wire R, LW, SW, BEQ, JMP, ADDI, ANDI, ORI, BNE;
    wire `ctrl_sig;

    assign  R    = op==6'b000_000,
	        LW   = op==6'b100_011,
	        SW   = op==6'b101_011,
	        BEQ  = op==6'b000_100,
	        BNE  = op==6'b000_101,
	        JMP  = op==6'b000_010,
	        ADDI = op==6'b001_000,
	        ANDI = op==6'b001_100,
	        ORI  = op==6'b001_101;

    assign  ALUop2     = ANDI|ORI,
            InvBranch  = BNE,
            ZeroExtend = ANDI|ORI,
            RegDst     = R,
            ALUsrcB    = LW|SW|ADDI|ANDI|ORI,
            MemToReg   = LW,
            WriteReg   = R|LW|ADDI|ANDI|ORI,
            MemWrite   = SW,
            Branch     = BEQ|BNE,
            ALUop1     = R,
            ALUop0     = BEQ|BNE|ORI,
            Jump       = JMP;

    assign sig = {`ctrl_sig};

endmodule
