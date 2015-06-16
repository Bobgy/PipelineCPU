`timescale 1ns / 1ps
module RegFile(clk, rst, regA, regB, regW, Wdat, Adat, Bdat, RegWrite, regC, Cdat);   //�Ĵ���
	input clk, Rst, RegWrite;               //д��ѡ���ź�
	input [4:0] regA, regB, regW, regC;          //Դ�Ĵ�����Ŀ�ļĴ����ĵ�ַ
	input [31:0] Wdat;  //д��Ŀ�ļĴ���������
	output [31:0] Adat, Bdat, Cdat; //��Դ�Ĵ����ж�������������
	reg[31:0] r[31:0];
	reg[5:0] t; //��ʼ����ѭ������
	always @(posedge clk or posedge Rst)begin //��clk�����أ���д���ź�Ϊ1��ʱ��д���Ĵ�����
		if(Rst)begin
			for(t=0; t<32; t=t+1)
				r[t]=0;
		end else if(RegWrite)
			r[regW]=Wdat;
	end
	assign Adat=r[regA], Bdat=r[regB]; //�Ѷ�Ӧ���ŵļĴ�������
	assign Cdat=r[regC]; //Ϊ�˲���
endmodule
