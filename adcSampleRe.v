// For real simple

module adcSampleRe(
					input clk,uart_clk,
					input reset_n,
					input readStart,
					input txBusy,
					input [7:0] ramReData,

					output [7:0] ramReAddr,
					output ramRe,
					output [7:0] txData,
					output txPos,
					output readBusy
				);
//===================================================================
assign  ramReAddr = ramReCnt[7:0];		
assign      ramRe = ramREEn;
assign     txData = txDataT[7:0];
assign      txPos = startS;
assign   readBusy = ramBusy;
//===================================================================
reg readStart2;
always @(posedge uart_clk or negedge reset_n) begin
	if (!reset_n) begin
		// reset
		readStart2 <= 0;
	end
	else 	readStart2 <= readStart;
end
//===================================================================
//2
reg [1:0] ramReState;
reg [7:0] txDataCnt,txDataT;
reg startS;
reg [7:0]ramReCnt;
always @(posedge uart_clk or negedge reset_n) begin
	if (!reset_n) begin
		// reset
	  ramReState <= 2'd0;
	  ramReCnt <= 8'd0;
	end
	else
	begin
		case(ramReState)
			2'd0:
			begin
			    if(readStart2 && !readStart)
					ramReState <= 2'd1;
			    else
					ramReState <= 2'd0;	
			 end
			2'd1:
			begin if(!txBusy) begin
						if(txDataCnt == 8'd205)
						begin
								ramReState <= 2'd0;
								txDataCnt <= 8'd0;
						end
						else begin
								txDataCnt <= txDataCnt + 8'd1;
								startS <= 1'd1;
								txDataT <= txDataT_r;
								ramReState <= 2'd2;
								if((txDataCnt > 8'd1) && (txDataCnt <= 8'd201))
										ramReCnt <= ramReCnt + 8'd1;
								else
										ramReCnt <= 8'd0;
						end
					end
			 end
			2'd2:
			begin
					startS <= 1'd0;
					ramReState <= 2'd1;
			 end
		endcase
	end
end
//===================================================================
reg [7:0] txDataT_r;
always @(posedge uart_clk or negedge reset_n) begin
	if (!reset_n) begin
		txDataT_r <= 8'ha0;
	end
	else 
	begin
	      if(txDataCnt <= 8'd2)
				txDataT_r <= 8'ha0;
	      else if(txDataCnt > 8'd2 && txDataCnt <= 8'd202)
				txDataT_r <= ramReData;
			else if(txDataCnt == 8'd203)
				txDataT_r <= 8'h0d;
			else if(txDataCnt == 8'd204)
				txDataT_r <= 8'h0a;
			else txDataT_r <= 8'd0;
	end
end
//===================================================================
reg ramREEn;
always @(posedge clk or negedge reset_n) begin
	if (!reset_n)
		ramREEn <= 1'd0;
	else
	begin
		if(ramReState == 2'd0)
			ramREEn <= 1'd0;
		else 
			ramREEn <= 1'd1;
	end
end
//===================================================================
reg ramBusy;
always @(posedge clk or negedge reset_n) begin
	if (!reset_n) begin
		ramBusy <= 0;
	end
	else if(ramReState == 2'd0)
		ramBusy <= 1'd0;
	else
		ramBusy <= 1'd1;
end
endmodule
