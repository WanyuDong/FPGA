module duty(
	input clk,rst,
	input sig,
	input div_clk,
	output[31:0] out_high,
	output[31:0] out_T
	);
//============================================
wire clk_high;
assign clk_high =(clk && sig)? 1 : 0;
//============================================
reg start;	
always @(posedge sig or negedge rst) begin
	if (!rst) begin
		// reset
		start <= 1'd0;	
	end
	else if (div_clk==1) begin
			//start count
			start <= 1; 
			end 
			else  if (start == 1 && div_clk==0) begin
				//end counting
				out_high <= cont_high + 1;//output when it down first time;
				out_T <= cont_T + 1;
				start <= 0;//count completed
			end
end
	
//============================================
reg [31:0] cont_T;
always @(posedge clk or negedge rst) begin
	if (!rst) begin
			// reset	
		cont_T <= 32'd0;	
	end
	else if(start==1) begin
			cont_T <= cont_T + 1;
		  end else begin
			cont_T <= 0;
		  end
end

//============================================	
reg [31:0] cont_high;
always @(posedge clk_high or negedge rst) begin
		if (!rst) begin
			// reset		
			cont_high <= 32'd0;
		end
		else if (start==1) begin
			//has started
			cont_high <= cont_high + 1;
		end else begin
			cont_high <= 0;//reset counter
		end
end
//============================================
endmodule
