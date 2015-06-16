`timescale 1ns / 1ps
module adder_4bit(
  input [3:0]A,
  input [3:0]B,
  input Ci,
  output [3:0]S,
  output Co
);
  wire [2:0]C;
  full_adder m0(A[0], B[0], Ci, S[0], C[0]),
          m1(A[1], B[1], C[0], S[1], C[1]),
          m2(A[2], B[2], C[1], S[2], C[2]),
          m3(A[3], B[3], C[2], S[3], Co);
endmodule
