module Cont_Rre(
	input clk,rst,
	input div_clk,  //threshold clk
	input signal_x,
	output[31:0] fcont_0,
	output[31:0] fcont_x
	);
/*========================================================
	Measure the frequence of signal x .
	fre_clk/fcont_0 = fre_sigX/fcont_x;
	so,the fre of signal x is:
	
	 fre = fre_clk*fcont_x/fcont_0;
	 
	 error is around the period of clk.
========================================================*/
	//count signal_X
	reg [31:0] cont_x;
	always @(posedge signal_x or negedge rst) begin
		if (!rst) begin
			// reset		
		end
		else if(START==1) begin
				cont_x = cont_x +1;
			  end else begin
				cont_x <= 0;
			  end
	end
	//START is kind of reg, can it be used as @posedg
//========================================================	
	//count cont_0
	reg [31:0] cont_0;
	always @(posedge clk or negedge rst) begin
		if (!rst) begin
			// reset		
		end
		else if (START==1) begin
			//has started
			cont_0 <= cont_0 + 1;
		end else begin
			cont_0 <= 0;//reset counter
		end
	end
//========================================================	
	reg START;
	reg [31:0] fcont_0,fcont_x;
	//control start&end;count cont_x;	
	always @(posedge signal_x or negedge rst) begin
		if (!rst) begin
			// reset		
		end
		else
				 if (div_clk==1) begin
					//start count
					START <= 1; 
				end 
				else  if (START == 1 && div_clk==0) begin
					//end counting
					fcont_0 <= cont_0;//output when it down first time;
					fcont_x <= cont_x + 1;
					START <= 0;//count completed
				end
		end
//========================================================

endmodule
