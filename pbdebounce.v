`timescale 1ns / 1ps
module pbdebounce
	(input wire clk,
	input wire button,
	output reg pbreg);
	
	reg [7:0] pbshift;
	wire clk_1ms;
	timer_1ms m0(clk, clk_1ms);
	always@(posedge clk_1ms) begin
		pbshift=pbshift<<1;//����1λ
		pbshift[0]=button;
		if (pbshift==0)
		pbreg=0;
		if (pbshift==8'hFF)// pbshift��λȫΪ1
		pbreg=1;
	end
endmodule