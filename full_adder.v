`timescale 1ns / 1ps
module full_adder(
	input A,
	input B,
	input Ci,
	output S,
	output Co
);
	wire xorAB, andAB, w;
	XOR2  m0(.I0(A), .I1(B), .O(xorAB)),
			m1(.I0(xorAB), .I1(Ci), .O(S));
	AND2  m2(.I0(A), .I1(B), .O(andAB)),
			m3(.I0(xorAB), .I1(Ci), .O(w));
	OR2   m4(.I0(andAB), .I1(w), .O(Co));
endmodule
