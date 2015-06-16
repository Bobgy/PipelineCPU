`timescale 1ns / 1ps
module adder_32bit(
	input [31:0]A,
	input [31:0]B,
	input Ci, //输入的进位
	output [31:0]S,
	output CF, //输出的进位标志(Carry Flag)
	output OF //输出的有符号数的溢出标志(Overflow Flag)
);
	wire C[6:0];
	adder_4bit  m0(A[3:0], B[3:0], Ci, S[3:0], C[0]),
				m1(A[ 7: 4], B[ 7: 4], C[0], S[ 7: 4], C[1]),
				m2(A[11: 8], B[11: 8], C[1], S[11: 8], C[2]),
				m3(A[15:12], B[15:12], C[2], S[15:12], C[3]),
				m4(A[19:16], B[19:16], C[3], S[19:16], C[4]),
				m5(A[23:20], B[23:20], C[4], S[23:20], C[5]),
				m6(A[27:24], B[27:24], C[5], S[27:24], C[6]),
				m7(A[31:28], B[31:28], C[6], S[31:28], CF);
	XOR2 m8(.I0(A[31]), .I1(B[31]), .O(xorAB31)),
		  m9(.I0(A[31]), .I1(S[31]), .O(xorAS31));
	INV  mA(.I(xorAB31), .O(NxorAB31));
	AND2 mB(.I0(NxorAB31), .I1(xorAS31), .O(OF));
	//OF = ~(A[31]^B[31])&(A[31]^S[31])
	//溢出发生在A和B同号（A[31]==B[31]）
	//且与计算结果异号（A[31]!=S[31]）的时候
endmodule
