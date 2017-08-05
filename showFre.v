// LED

module showFre(
	input clk,clk_1k,rst,
	input [15:0]binary,
	output[5:0] del, //位选
	output[6:0] seg, //值选
	output dp //小数点
	);
//========================================
reg[15:0] cnt16;
always @(posedge clk_1k or negedge rst) begin
	if (!rst) begin
		// reset
		cnt16 <= 16'd0;
	end
	else if(cnt16 == 16'd500)begin
		cnt16 <= 16'd0;
	end
	else begin
		cnt16 <= cnt16 + 16'd1;
	end
end
//========================================
reg[9:0] binary_r;
always @(posedge clk_1k or negedge rst) begin
	if (!rst) begin
		// reset
		binary_r <= 10'd1000;
	end
	else if(cnt16 == 16'd0)begin
		binary_r <= binary[9:0];
	end
	else begin
		binary_r <= binary_r;
	end
end
//==========================================
wire[20:0] quo;
wire[15:0] quo_b;

L_DIV div(.denom(binary_r),.numer(21'd2000000),.quotient(quo));
assign quo_b = (quo[15:0]-16'd2);
//==========================================
wire [3:0] a,b,c,d,e,f;
bin2bcd step1(.clk(clk),
			  .rst(rst),
			  .binary(quo_b),
			  .W(a),
			  .Q(b),
			  .B(c),
			  .S(d),
			  .G(e)
			  );
//assign a = 4'd1;
//assign b = 4'd2;
//assign c = 4'd3;
//assign d = 4'd4;
//assign e = 4'd5;
assign f = 4'd0;
//==========================================
digitron step2(.clk(clk_1k),
			   .rst(rst),
			   .num0(a),
			   .num1(b),
			   .num2(c),
			   .num3(d),
			   .num4(e),
			   .num5(f),
			   .dp_in(6'b000100),
			   .del(del),
			   .seg(seg),
			   .dp(dp)
			   );

//==========================================
endmodule


