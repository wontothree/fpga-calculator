`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:26:02 11/16/2020 
// Design Name: 
// Module Name:    my_calculator_project 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module my_calculator_project( n1, n2, n3, n4, n5, n6, n7, n8 ,n9, n0,
clk, resetn, load, clear, Select_d1, Select_d2,
mul, div, sum, sub, div_sw, eq, sq,
LCD_E, LCD_RS, LCD_RW, LCD_DATA,
seg_com, seg_data
);

	input n1, n2, n3, n4, n5, n6, n7, n8, n9, n0;
	input clk, resetn, load, clear, Select_d1, Select_d2;
	input mul, div, sum, sub, div_sw, eq, sq;
	
	output wire LCD_E;
	output reg LCD_RS, LCD_RW;
	output reg [7:0] LCD_DATA;
	output reg [3:0]seg_com;
	output reg [7:0]seg_data;
	
	integer cnt_scan;
	
	
	//one shot ȸ��
	wire en, enable;
	assign en=n1|n2|n3|n4|n5|n6|n7|n8|n9|n0|load|clear;
	reg en_reg;
	assign enable=en&~en_reg;
	
	always@(posedge clk)
	begin
	en_reg = en;
	end
	
	//���ڰ� �Է�(���� ���������� ���ڸ����� ��ĭ�� �̵��ϰ� 1�� �ڸ����� ������ư�� �ش��ϴ� ���� �ԷµǴ� ����)
	reg [15:0]reg_data;
	reg [4:0]one, ten, hun, tho;
	reg [15:0]input_d1, input_d2;
	
	always@(posedge clk or negedge resetn)
	begin
	if(~resetn)
	begin
		one=0;
		ten=0;
		hun=0;
		tho=0;
	end
	
	else
	begin
		if(enable)
		begin
			if(n1)
				begin tho=hun; hun=ten; ten=one; one=4'd1; end
			else if(n2)
				begin tho=hun; hun=ten; ten=one; one=4'd2; end
			else if(n3)
				begin tho=hun; hun=ten; ten=one; one=4'd3; end	
			else if(n4)
				begin tho=hun; hun=ten; ten=one; one=4'd4; end	
			else if(n5)
				begin tho=hun; hun=ten; ten=one; one=4'd5; end	
			else if(n6)
				begin tho=hun; hun=ten; ten=one; one=4'd6; end	
			else if(n7)
				begin tho=hun; hun=ten; ten=one; one=4'd7; end	
			else if(n8)
				begin tho=hun; hun=ten; ten=one; one=4'd8; end	
			else if(n9)
				begin tho=hun; hun=ten; ten=one; one=4'd9; end	
			else if(n0)
				begin tho=hun; hun=ten; ten=one; one=4'd0; end	
			else if(clear)
				begin one=0; ten=0; hun=0; tho=0; end
		end
	end
end
	
	always@(posedge clk or negedge resetn)
	begin
		if(~resetn) reg_data=0;
		
		else
		begin
			reg_data=one*1'd1 + ten*4'd10 + hun*7'd100 + tho*10'd1000;
		end
	end
	
	always@(posedge clk or negedge resetn)
	begin
	if(~resetn)
	begin
		input_d1=0;
		input_d2=0;
	end
	
	else
	begin
	if(enable)
	begin
		if(load&&Select_d1)
		begin 
		input_d1=reg_data;
		end
		
		else if(load&&Select_d2)
		begin 
		input_d2=reg_data;
		end
	end
	end
end
	

	//data_input 10����->2����
	reg [15:0]reg_input_d1, reg_input_d2;
	reg [3:0]input1_a, input1_b, input1_c, input1_d;
	reg [3:0]input2_a, input2_b, input2_c, input2_d;
	
	always@(posedge clk or negedge resetn)
	begin
	if(~resetn)
	begin
		reg_input_d1=0; input1_a=0; input1_b=0; input1_c=0; input1_d=0;
	end
	//data1
	else
	begin
		if(load&&Select_d1)
		begin 
		reg_input_d1 = input_d1;
		end
		
		else if(reg_input_d1>=14'd1000)
		begin
		reg_input_d1 = reg_input_d1-32'd1000;
		input1_d= input1_d+1;
		end
		
		else if(reg_input_d1>=14'd100)
		begin
		reg_input_d1 = reg_input_d1-32'd100;
		input1_c= input1_c+1;
		end
		
		else if(reg_input_d1>=14'd10)
		begin
		reg_input_d1 = reg_input_d1-32'd10;
		input1_b= input1_b+1;
		end
		
		else if(reg_input_d1<14'd10)
		begin
		input1_a=reg_input_d1;
		end
	end
end
	//data2
	always@(posedge clk or negedge resetn)
	begin
	if(~resetn)
	begin
		reg_input_d2=0; input2_a=0; input2_b=0; input2_c=0; input2_d=0;
	end
	
	else
	begin
		if(load&&Select_d2)
		begin 
		reg_input_d2 = input_d2;
		end
		
		else if(reg_input_d2>=14'd1000)
		begin
		reg_input_d2 = reg_input_d2-32'd1000;
		input2_d= input2_d+1;
		end
		
		else if(reg_input_d2>=14'd100)
		begin
		reg_input_d2 = reg_input_d2-32'd100;
		input2_c= input2_c+1;
		end
		
		else if(reg_input_d2>=14'd10)
		begin
		reg_input_d2 = reg_input_d2-32'd10;
		input2_b= input2_b+1;
		end
		
		else if(reg_input_d2<14'd10)
		begin
		input2_a=reg_input_d2;
		end
	end
end
	
	//reg_data FND ǥ��
	always@(posedge clk)
	begin
		if(~resetn)
		begin
		cnt_scan = 0;
		end
		
		else
			if(cnt_scan>=3)
			begin
			cnt_scan=0;
			end
			else
			begin
			cnt_scan = cnt_scan+1;
			end

	end
	
	always@(posedge clk)
	begin
		if(~resetn)
		begin
			seg_com=4'hF;
			seg_data=8'h00;
		end
		else
		begin
			if(cnt_scan==0)
				begin
				seg_com=4'hE;
					begin
						if(one==4'd1) begin seg_data=8'b01100000; end
						else if(one==4'd2) begin seg_data=8'b11011010; end
						else if(one==4'd3) begin seg_data=8'b11110010; end
						else if(one==4'd4) begin seg_data=8'b01100110; end
						else if(one==4'd5) begin seg_data=8'b10110110; end
						else if(one==4'd6) begin seg_data=8'b10111110; end
						else if(one==4'd7) begin seg_data=8'b11100000; end
						else if(one==4'd8) begin seg_data=8'b11111110; end
						else if(one==4'd9) begin seg_data=8'b11110110; end
						else if(one==4'd0) begin seg_data=8'b11111100; end
					end
				end
			else if(cnt_scan==1)
				begin
				seg_com=4'hD;
					begin
						if(ten==4'd1) begin seg_data=8'b01100000; end
						else if(ten==4'd2) begin seg_data=8'b11011010; end
						else if(ten==4'd3) begin seg_data=8'b11110010; end
						else if(ten==4'd4) begin seg_data=8'b01100110; end
						else if(ten==4'd5) begin seg_data=8'b10110110; end
						else if(ten==4'd6) begin seg_data=8'b10111110; end
						else if(ten==4'd7) begin seg_data=8'b11100000; end
						else if(ten==4'd8) begin seg_data=8'b11111110; end
						else if(ten==4'd9) begin seg_data=8'b11110110; end
						else if(ten==4'd0) begin seg_data=8'b11111100; end
					end
				end
			else if(cnt_scan==2)
				begin
				seg_com=4'hB;
					begin
						if(hun==4'd1) begin seg_data=8'b01100000; end
						else if(hun==4'd2) begin seg_data=8'b11011010; end
						else if(hun==4'd3) begin seg_data=8'b11110010; end
						else if(hun==4'd4) begin seg_data=8'b01100110; end
						else if(hun==4'd5) begin seg_data=8'b10110110; end
						else if(hun==4'd6) begin seg_data=8'b10111110; end
						else if(hun==4'd7) begin seg_data=8'b11100000; end
						else if(hun==4'd8) begin seg_data=8'b11111110; end
						else if(hun==4'd9) begin seg_data=8'b11110110; end
						else if(hun==4'd0) begin seg_data=8'b11111100; end
					end
				end
			else if(cnt_scan==3)
				begin
				seg_com=4'h7;
					begin
						if(tho==4'd1) begin seg_data=8'b01100000; end
						else if(tho==4'd2) begin seg_data=8'b11011010; end
						else if(tho==4'd3) begin seg_data=8'b11110010; end
						else if(tho==4'd4) begin seg_data=8'b01100110; end
						else if(tho==4'd5) begin seg_data=8'b10110110; end
						else if(tho==4'd6) begin seg_data=8'b10111110; end
						else if(tho==4'd7) begin seg_data=8'b11100000; end
						else if(tho==4'd8) begin seg_data=8'b11111110; end
						else if(tho==4'd9) begin seg_data=8'b11110110; end
						else if(tho==4'd0) begin seg_data=8'b11111100; end
					end
				end
		end
	end
	
	///����
	
	reg[31:0]dividend, divisor;
	reg [31:0]quo;//quotient ��	
	reg [31:0]rest;
	reg [4:0] q;
	
	always@(posedge clk or negedge resetn)
	begin
	if(~resetn)
		begin
			dividend=0; divisor=0; quo=0; rest=0;
		end
	else
		begin
		if(div_sw==1) begin dividend = input_d1; divisor = input_d2; end
		else if(dividend>divisor) begin dividend = dividend - divisor; quo = quo+1; end		
		else if(dividend==divisor)begin quo = quo+1; rest=0; end
		else begin dividend = rest; end


		end
	end
	
	
	

	//output �����ϱ�
	reg [31:0] output_data;
	reg [31:0] output_data1;
	reg [31:0] output_data2;
				
	reg sub_fac;
	reg div_fac;
	
	reg mul_lcd, div_lcd, sum_lcd, sub_lcd, sq_lcd;
	
	always@(posedge clk or negedge resetn)
	begin
	if(~resetn)
	begin
	output_data=0; sub_fac=0; div_fac=0;
	mul_lcd=0; div_lcd=0; sum_lcd=0; sub_lcd=0; sq_lcd=0;
	end
	
	else
	begin
		if(mul&&eq)//����
		begin
			output_data=input_d1*input_d2;
			mul_lcd=1;
		end
		
		else if(div&&eq)//������
		begin
			div_lcd=1;
			output_data1=quo;
			output_data2=rest;
			div_fac=1;
		end
		
		else if(sq&&eq)//����
		begin
			output_data=input_d1*input_d1;
			sq_lcd=1;
		end
		
		else if(sum&&eq)//����
		begin
			output_data=input_d1+input_d2;
			sum_lcd=1;
		end
		
		else if(sub&&eq)//����
		begin
		sub_lcd=1;
			if(input_d1<input_d2)begin output_data = input_d2-input_d1; sub_fac=1; end
			else begin output_data = input_d1-input_d2; sub_fac=0; end
		end
	end
end

	
	reg [31:0]reg_output_data;
	reg [31:0]reg_output_data1;
	reg [31:0]reg_output_data2;
	reg [3:0] output_a, output_b, output_c, output_d, output_e, output_f, output_g, output_h, output_i;
	
	always@(posedge clk or negedge resetn)
	begin
		if(~resetn)
		begin
			reg_output_data=0; output_a=0; output_b=0; output_c=0; output_d=0; output_e=0; output_f=0; output_g=0; output_h=0; output_i=0;
		end
		
		else if(div_sw)
		begin
			if(eq) begin reg_output_data1=output_data1; reg_output_data2=output_data2; end
			
			else if(reg_output_data1>=32'd1000) begin reg_output_data1 = reg_output_data1-32'd1000; output_i=output_i+1'b1; end
			else if(reg_output_data1>=32'd100) begin reg_output_data1 = reg_output_data1-32'd100; output_h=output_h+1'b1; end
			else if(reg_output_data1>=32'd10) begin reg_output_data1 = reg_output_data1-32'd10; output_g=output_g+1'b1; end
			else if(reg_output_data1<32'd10) begin output_f = reg_output_data1; end
			
			else if(reg_output_data2>=32'd1000) begin reg_output_data2 = reg_output_data2-32'd1000; output_d=output_d+1'b1; end
			else if(reg_output_data2>=32'd100) begin reg_output_data2 = reg_output_data2-32'd100; output_c=output_c+1'b1; end
			else if(reg_output_data2>=32'd10) begin reg_output_data2 = reg_output_data2-32'd10; output_b=output_b+1'b1; end
			else if(reg_output_data2<32'd10) begin output_a = reg_output_data2; end
		end
	
		
		else
		begin
			if(eq) begin reg_output_data=output_data; end
			else if(reg_output_data>=32'd100000000) begin reg_output_data = reg_output_data-32'd100000000; output_i=output_i+1'b1; end
			else if(reg_output_data>=32'd10000000) begin reg_output_data = reg_output_data-32'd10000000; output_h=output_h+1'b1; end
			else if(reg_output_data>=32'd1000000) begin reg_output_data = reg_output_data-32'd1000000; output_g=output_g+1'b1; end
			else if(reg_output_data>=32'd100000) begin reg_output_data = reg_output_data-32'd100000; output_f=output_f+1'b1; end
			else if(reg_output_data>=32'd10000) begin reg_output_data = reg_output_data-32'd10000; output_e=output_e+1'b1; end
			else if(reg_output_data>=32'd1000) begin reg_output_data = reg_output_data-32'd1000; output_d=output_d+1'b1; end
			else if(reg_output_data>=32'd100) begin reg_output_data = reg_output_data-32'd100; output_c=output_c+1'b1; end
			else if(reg_output_data>=32'd10) begin reg_output_data = reg_output_data-32'd10; output_b=output_b+1'b1; end
			else if(reg_output_data<32'd10) begin output_a = reg_output_data; end
		end
	end
	//lcd
	
	reg [2:0]state;
	parameter delay=3'b000,
				 function_set=3'b001,
				 entry_mode=3'b010,
				 disp_onoff=3'b011,
				 line1=3'b100,
				 line2=3'b101;
	integer cnt;
	integer cnt_100hz;
	reg clk_100hz;
	
	always@(negedge resetn or posedge clk)
	begin
		if(~resetn)
			begin
			cnt_100hz=0;
			clk_100hz=1'b0;
			end
		else if(cnt_100hz>=4)
			begin
			cnt_100hz=0;
			clk_100hz=~clk_100hz;
			end
		else
			cnt_100hz=cnt_100hz+1;
	end
	
	always@(negedge resetn or posedge clk_100hz)
	begin
	if(~resetn)
	begin	state=delay; end
	else
	begin
	case(state)
	delay : begin if(cnt==70) state=function_set; end
	function_set : begin if(cnt==30) state = disp_onoff; end
	disp_onoff : begin if(cnt==30) state = entry_mode; end
	entry_mode : begin if(cnt==30) state = line1; end
	line1 : begin if(cnt==20) state = line2; end
	line2 : begin if(cnt==20) state = line1; end
	default : state = delay;
	
	endcase
	end
	end
	
	always@ (negedge resetn or posedge clk_100hz)
	begin
	if(~resetn)
	begin cnt=0; end
	else
	begin
		case(state)
		delay : begin if(cnt>=70) cnt=0; else cnt=cnt+1; end
		function_set : begin if(cnt>=30) cnt=0; else cnt=cnt+1; end
		disp_onoff : begin if(cnt>=30) cnt=0; else cnt=cnt+1; end
		entry_mode : begin if(cnt>=30) cnt=0; else cnt=cnt+1; end
		line1 : begin if(cnt>=20) cnt=0; else cnt=cnt+1; end
		line2 : begin if(cnt>=20) cnt=0; else cnt=cnt+1; end
		default : cnt=0;
		endcase
		end
	end
	
	always@(negedge resetn or posedge clk_100hz)
	begin
	if(~resetn)
		begin
		LCD_RS=1'b1;
		LCD_RW=1'b1;
		LCD_DATA=8'b00100000;
		end
	
	else
		begin
		if(div_sw==1 && divisor!=0)//////////////////////////////
			begin
			case(state)
			function_set : begin LCD_RS=1'b0; LCD_RW=1'b0; LCD_DATA=8'b00111100; end
			disp_onoff : begin LCD_RS=1'b0; LCD_RW=1'b0; LCD_DATA=8'b00001110; end
			entry_mode : begin LCD_RS=1'b0; LCD_RW=1'b0; LCD_DATA=8'b00000110; end
			line1 : begin
				  LCD_RW=1'b0;
				  case(cnt)
				  0 : begin LCD_RS=1'b0; LCD_DATA=8'b10000000; end
				  1 : begin LCD_RS=1'b1; LCD_DATA=8'b00100000; end
				  2 : begin LCD_RS=1'b1; LCD_DATA=8'b00100000; end
				  3 : begin LCD_RS=1'b1; LCD_DATA={4'b0011, input1_d}; end
				  4 : begin LCD_RS=1'b1; LCD_DATA={4'b0011, input1_c}; end
				  5 : begin LCD_RS=1'b1; LCD_DATA={4'b0011, input1_b}; end
				  6 : begin LCD_RS=1'b1; LCD_DATA={4'b0011, input1_a}; end
				  7 : begin LCD_RS=1'b1; LCD_DATA=8'b00100000; end
				  8 : begin
							LCD_RS=1'b1;
							if(mul_lcd==1) begin LCD_DATA=8'b01111000; end
							else if(div_lcd==1) begin LCD_DATA=8'b00101111; end
							else if(sum_lcd==1) begin LCD_DATA=8'b00101011; end
							else if(sub_lcd==1) begin LCD_DATA=8'b00101101; end
							else if(sq_lcd==1) begin LCD_DATA=8'b01011110; end//^
							else begin LCD_DATA=8'b0010000; end
						end
				  9 : begin LCD_RS=1'b1; LCD_DATA=8'b00100000; end
				  10 : begin LCD_RS=1'b1; LCD_DATA=8'b00100000; end
				  11 : begin LCD_RS=1'b1; LCD_DATA=8'b00100000; end
				  12 : begin LCD_RS=1'b1; LCD_DATA={4'b0011, input2_d}; end
				  13 : begin LCD_RS=1'b1; LCD_DATA={4'b0011, input2_c}; end
				  14 : begin LCD_RS=1'b1; LCD_DATA={4'b0011, input2_b}; end
				  15 : begin LCD_RS=1'b1; LCD_DATA={4'b0011, input2_a}; end
				  16 : begin LCD_RS=1'b1; LCD_DATA=8'b00100000; end
				  default : begin LCD_RS=1'b1; LCD_DATA=8'b00100000; end				  
				  endcase
				 end

		line2 : begin
				  LCD_RW=1'b0;
				  case(cnt)
				  0 : begin LCD_RS=1'b0; LCD_DATA=8'b11000000; end
				  1 : begin LCD_RS=1'b1; LCD_DATA=8'b01010001; end //Q
				  2 : begin LCD_RS=1'b1; LCD_DATA=8'b00111101; end //=
				  3 : begin LCD_DATA={4'b0011,output_i}; end
				  4 : begin LCD_DATA={4'b0011,output_h}; end
				  5 : begin LCD_DATA={4'b0011,output_g}; end
				  6 : begin LCD_DATA={4'b0011,output_f}; end
				  7 : begin LCD_RS=1'b1; LCD_DATA=8'b00100000; end
				  8 : begin LCD_RS=1'b1; LCD_DATA=8'b01010010; end //R
				  9 : begin LCD_RS=1'b1; LCD_DATA=8'b00111101; end //=
				  10 : begin LCD_DATA={4'b0011,output_d}; end
				  11 : begin LCD_DATA={4'b0011,output_c}; end
				  12 : begin LCD_DATA={4'b0011,output_b}; end
				  13 : begin LCD_DATA={4'b0011,output_a}; end
				  14 : begin LCD_RS=1'b1; LCD_DATA=8'b00100000; end
				  15 : begin LCD_RS=1'b1; LCD_DATA=8'b00100000; end
				  16 : begin LCD_RS=1'b1; LCD_DATA=8'b00100000; end
				  
				  default : begin LCD_RS=1'b1; LCD_DATA=8'b00100000; end
				  
				  endcase
				  end
				  
		default : begin LCD_RS=1'b1; LCD_RW=1'b1; LCD_DATA=8'b00000000; end
		endcase
		end
		
	else if(divisor==0&&div_lcd==1)///////////////////////////
	begin
		case(state)
		function_set : begin LCD_RS=1'b0; LCD_RW=1'b0; LCD_DATA=8'b00111100; end
		disp_onoff : begin LCD_RS=1'b0; LCD_RW=1'b0; LCD_DATA=8'b00001110; end
		entry_mode : begin LCD_RS=1'b0; LCD_RW=1'b0; LCD_DATA=8'b00000110; end
		line1 : begin
				  LCD_RW=1'b0;
				  case(cnt)
				  0 : begin LCD_RS=1'b0; LCD_DATA=8'b10000000; end
				  1 : begin LCD_RS=1'b1; LCD_DATA=8'b00100000; end
				  2 : begin LCD_RS=1'b1; LCD_DATA=8'b00100000; end
				  3 : begin LCD_RS=1'b1; LCD_DATA={4'b0011, input1_d}; end
				  4 : begin LCD_RS=1'b1; LCD_DATA={4'b0011, input1_c}; end
				  5 : begin LCD_RS=1'b1; LCD_DATA={4'b0011, input1_b}; end
				  6 : begin LCD_RS=1'b1; LCD_DATA={4'b0011, input1_a}; end
				  7 : begin LCD_RS=1'b1; LCD_DATA=8'b00100000; end
				  8 : begin
						LCD_RS=1'b1;
						if(mul_lcd==1) begin LCD_DATA=8'b01111000; end
						else if(div_lcd==1) begin LCD_DATA=8'b00101111; end
						else if(sum_lcd==1) begin LCD_DATA=8'b00101011; end
						else if(sub_lcd==1) begin LCD_DATA=8'b00101101; end
						else if(sq_lcd==1) begin LCD_DATA=8'b01011110; end//^
						else begin LCD_DATA=8'b0010000; end
						end
				  9 : begin LCD_RS=1'b1; LCD_DATA=8'b00100000; end
				  10 : begin LCD_RS=1'b1; LCD_DATA=8'b00100000; end
				  11 : begin LCD_RS=1'b1; LCD_DATA=8'b00100000; end
				  12 : begin LCD_RS=1'b1; LCD_DATA={4'b0011, input2_d}; end
				  13 : begin LCD_RS=1'b1; LCD_DATA={4'b0011, input2_c}; end
				  14 : begin LCD_RS=1'b1; LCD_DATA={4'b0011, input2_b}; end
				  15 : begin LCD_RS=1'b1; LCD_DATA={4'b0011, input2_a}; end
				  16 : begin LCD_RS=1'b1; LCD_DATA=8'b00100000; end
				  default : begin LCD_RS=1'b1; LCD_DATA=8'b00100000; end				  
				  endcase
				 end

		line2 : begin
				  LCD_RW=1'b0;
				  case(cnt)
				  0 : begin LCD_RS=1'b0; LCD_DATA=8'b11000000; end
				  1 : begin LCD_RS=1'b1; LCD_DATA=8'b00111101; end //=
				  2 : begin LCD_DATA=8'b00100000; end
				  3 : begin LCD_DATA=8'b01011000; end//x
				  4 : begin LCD_DATA=8'b01011000; end
				  5 : begin LCD_DATA=8'b01011000; end
				  6 : begin LCD_DATA=8'b01011000; end
				  7 : begin LCD_DATA=8'b01011000; end
				  8 : begin LCD_DATA=8'b01011000; end
				  9 : begin LCD_DATA=8'b01011000; end
				  10 : begin LCD_DATA=8'b01011000; end
				  
				  11 : begin LCD_DATA=8'b01011000; end
				  
				  12 : begin LCD_DATA=8'b01011000; end
				  13 : begin LCD_DATA=8'b01011000; end
				  14 : begin LCD_DATA=8'b01011000; end
				  15 : begin LCD_DATA=8'b01011000; end
				  16 : begin LCD_DATA=8'b01011000; end
				  default : begin LCD_RS=1'b1; LCD_DATA=8'b00100000; end
				  
				  endcase
				  end
				  
		default :begin LCD_RS=1'b1; LCD_RW=1'b1; LCD_DATA=8'b00000000; end
		endcase
		end
		
		else if(div_sw==0)//////////////////////
		begin
		case(state)
		function_set : begin LCD_RS=1'b0; LCD_RW=1'b0; LCD_DATA=8'b00111100; end
		disp_onoff : begin LCD_RS=1'b0; LCD_RW=1'b0; LCD_DATA=8'b00001110; end
		entry_mode : begin LCD_RS=1'b0; LCD_RW=1'b0; LCD_DATA=8'b00000110; end
		line1 : begin
				  LCD_RW=1'b0;
				  case(cnt)
				  0 : begin LCD_RS=1'b0; LCD_DATA=8'b10000000; end
				  1 : begin LCD_RS=1'b1; LCD_DATA=8'b00100000; end
				  2 : begin LCD_RS=1'b1; LCD_DATA=8'b00100000; end
				  3 : begin LCD_RS=1'b1; LCD_DATA={4'b0011, input1_d}; end
				  4 : begin LCD_RS=1'b1; LCD_DATA={4'b0011, input1_c}; end
				  5 : begin LCD_RS=1'b1; LCD_DATA={4'b0011, input1_b}; end
				  6 : begin LCD_RS=1'b1; LCD_DATA={4'b0011, input1_a}; end
				  7 : begin LCD_RS=1'b1; LCD_DATA=8'b00100000; end
				  8 : begin
						LCD_RS=1'b1;
						if(mul_lcd==1) begin LCD_DATA=8'b01111000; end
						else if(div_lcd==1) begin LCD_DATA=8'b00101111; end
						else if(sum_lcd==1) begin LCD_DATA=8'b00101011; end
						else if(sub_lcd==1) begin LCD_DATA=8'b00101101; end
						else if(sq_lcd==1) begin LCD_DATA=8'b01011110; end//^
						else begin LCD_DATA=8'b0010000; end
						end
				  9 : begin LCD_RS=1'b1; LCD_DATA=8'b00100000; end
				  10 : begin LCD_RS=1'b1; LCD_DATA=8'b00100000; end
				  11 : begin LCD_RS=1'b1; LCD_DATA=8'b00100000; end
				  12 : begin LCD_RS=1'b1; 
						 if(sq_lcd==0) begin LCD_DATA={4'b0011, input2_d}; end
						 else begin LCD_DATA=8'b00110000; end
						 end
				  13 : begin LCD_RS=1'b1;
						 if(sq_lcd==0) begin LCD_DATA={4'b0011, input2_c}; end
						 else begin LCD_DATA=8'b00110000; end
						 end
				  14 : begin LCD_RS=1'b1;
						 if(sq_lcd==0) begin LCD_DATA={4'b0011, input2_b}; end
						 else begin LCD_DATA=8'b00110000; end
						 end
				  15 : begin LCD_RS=1'b1;
						 if(sq_lcd==0) begin LCD_DATA={4'b0011, input2_a}; end
						 else begin LCD_DATA=8'b00110010; end
						 end
				  16 : begin LCD_RS=1'b1; LCD_DATA=8'b00100000; end
				  default : begin LCD_RS=1'b1; LCD_DATA=8'b00100000; end				  
				  endcase
				 end

		line2 : begin
				  LCD_RW=1'b0;
				  case(cnt)
				  0 : begin LCD_RS=1'b0; LCD_DATA=8'b11000000; end
				  1 : begin LCD_RS=1'b1; LCD_DATA=8'b00111101; end //=
				  2 : begin
						LCD_RS=1'b1;
						if(sub_fac==1) begin LCD_DATA=8'b00101101; end
						else begin LCD_DATA=8'b00100000; end
						end
				  3 : begin LCD_RS=1'b1; LCD_DATA={4'b0011,output_h}; end
				  4 : begin LCD_RS=1'b1; LCD_DATA={4'b0011,output_g}; end
				  5 : begin LCD_RS=1'b1; LCD_DATA={4'b0011,output_f}; end
				  6 : begin LCD_RS=1'b1; LCD_DATA={4'b0011,output_e}; end
				  7 : begin LCD_RS=1'b1; LCD_DATA={4'b0011,output_d}; end
				  8 : begin LCD_RS=1'b1; LCD_DATA={4'b0011,output_c}; end
				  9 : begin LCD_RS=1'b1; LCD_DATA={4'b0011,output_b}; end
				  10 : begin LCD_RS=1'b1; LCD_DATA={4'b0011,output_a}; end
				  
				  12 : begin
						 LCD_RS=1'b1; LCD_DATA=8'b00100000;//��ĭ
						 end
				  
				  12 : begin
						 LCD_RS=1'b1; LCD_DATA=8'b00100000;//��ĭ
						 end
				  13 : begin
						 LCD_RS=1'b1; LCD_DATA=8'b00100000;//��ĭ
						 end						 
				  14 : begin
						 LCD_RS=1'b1; LCD_DATA=8'b00100000;//��ĭ
						 end
				  15 : begin
						 LCD_RS=1'b1; LCD_DATA=8'b00100000;//��ĭ
						 end
				  16 : begin
						 LCD_RS=1'b1; LCD_DATA=8'b00100000;//��ĭ
						 end
						 
				  default : begin LCD_RS=1'b1; LCD_DATA=8'b00100000; end
				  endcase
				 end
				  
		default : begin LCD_RS = 1'b1; LCD_RW = 1'b1; LCD_DATA = 8'b00000000; end
		endcase
		end
	end
end
				  
				  
	assign LCD_E = clk_100hz;
				  
				  
				  
				  
				  
				  
				  
				  
endmodule 