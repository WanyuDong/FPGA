module inv_XY2(
	input clk,rst,
	input sig_x,sig_y,
	output[31:0] fcont
	);
//==========================================
reg pre_X,pre_Y;
always @(posedge clk or negedge rst) begin
	if (!rst) begin
		// reset
		pre_X <= 1'd0;
		pre_Y <= 1'd0;
	end
	else begin
		pre_X <= sig_x;
		pre_Y <= sig_y;
	end
end
//==========================================
reg [31:0] fcont;
reg start_cont;
always @(posedge clk or negedge rst) begin
 	if (!rst) begin
 		// reset
 		start_cont <= 1'd0;
 		fcont <= 32'd0;
 	end
 	else begin
			if (sig_x > pre_X && sig_y <= pre_Y) begin   //情况1：x和y有相位差时；x上升沿打开计数；
				start_cont<=1;
			end
			
			else if(sig_y > pre_Y && sig_x <= pre_X) begin //情况1：x和y有相位差时；y上升沿停止计数并取差值；
				start_cont<=0;
				fcont<= cont + 1;
			end
			
			else if(sig_y > pre_Y && sig_x > pre_X)begin //情况2：x和y无相位差，输出0；
				start_cont<=0;
				fcont<= 0;
			end
			else start_cont<= start_cont;
			end
 	end
//=====================================================	
reg[31:0] cont;
 always @(posedge clk or negedge rst) begin
 	if (!rst) begin
 		// reset
 		cont <= 32'd0;
 	end
 	else begin
		 if (start_cont == 1) begin
			cont <= cont + 1;
		 end else begin
			cont <= 0;
		 end
 	end
end
//=====================================================	
 endmodule 