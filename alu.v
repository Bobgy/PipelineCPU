`timescale 1ns / 1ps
module ALU(
	input [31:0] A,
	input signed[31:0] B,
	input [2:0] op,
	input [4:0] sa, //shift amount
	output [31:0] res,
	output o_zf
);
	wire[31:0] andAB, orAB, addAB, nB, r0, r1, sllB, srxB;
	wire CF, SF, slt; //Carry Flag, Sign Flag
	assign nB=~B; //��Bȡ��
	assign	andAB=A&B,
				orAB=A|B,
				sllB=B<<sa,
				srxB=op[0]?(B>>>sa):(B>>sa);
	adder_32bit adder_32(A, op[2]?nB:B, op[2], addAB, CF, OF); //����32λȫ���󣬷���CarryFlag��OverflowFlag
	assign SF=addAB[31], slt=SF^OF, o_zf=~|res; //SignFlag�ɼ�����������,(a<b)=SF xor OF
	//assign r0=op[1]?(op[0]?{31'b0,slt}:addAB):(op[0]?(orAB):(andAB)); //���ݿ��Ƶ��߼����ʺű���ʽд��

	assign r0 = op[1] ? (op[0]?sllB:addAB) : (op[0]?orAB:andAB);
	assign r1 = op[1] ? (op[0]?{31'b0,slt}:addAB) : srxB;
	assign res = op[2] ? r1 : r0;
endmodule
//Control	function
//000			and
//001			or
//010			add
//011			sll
//100			srl
//101			sra
//110			sub
//111			slt
