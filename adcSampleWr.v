// For real simple

module adcSampleWr(
					input clk,
					input reset_n,
					input [1:0] mode,
					input [7:0] adcData,
					input [7:0] trig,
					input busy,
					input location,
					output adcClk,
					output [7:0] ramWrData,
					output [7:0] ramWrAddr,
					output ramWr,
					output readStart,
					output reg led2
				);
//===================================================================
assign  adcClk = adcClk_r;		
assign  ramWrAddr = ramWrCnt[7:0];
assign  ramWr = ramWrEn;
assign  ramWrData = adcData;
assign  readStart = readS;
//===================================================================
//define 
parameter sampleCnt1MhzHalf = 100,
			 sampleCnt10MhzMax = 4000,
			 sampleCnt10MhzStep = 20,
			 sampleCnt200MhzMax = 200,
			 sampleCnt200MhzStep = 1;
//===================================================================
reg location_r;
always @(posedge clk or negedge reset_n) begin
	if (!reset_n) begin
		location_r <= 0;
	end
	else
		location_r <= location;
end
//===================================================================
reg [1:0]state;
always @(posedge clk or negedge reset_n) begin
	if (!reset_n) begin
		state <= 2'd0;
	end
	else 
	begin
		case(state)
			2'd0:
			begin
				if(!location_r && location && mode[1])
					state <= 2'd1;
				else if(mode == 2'd1)
					state <= 2'd1;
				else 
					state <= 2'd0;					
			end
			2'd1:
			begin
				if(cnt8 == cntCycle)
					state <= 2'd2;
				else 
					state <= 2'd0;
			end
			2'd2:
			begin
				if(cnt16 == sampleCnt)
					state <= 2'd0;
				else 
					state <= 2'd2;
			end
		endcase
	end
end
//===================================================================
reg [15:0] cnt16;
always @(posedge clk or negedge reset_n) begin
	if (!reset_n)
		cnt16 <= 16'd0;
	else if(state == 2'd0)
			cnt16 <= 16'd0;
	else if(state == 2'd2)
			cnt16 <= cnt16 + 16'd1;
end
//===================================================================
reg [7:0] cntCycle;
always @(posedge clk or negedge reset_n) begin
	if (!reset_n) begin
		cntCycle <= 2'd1;
	end
	else if(mode == 2'd1)
			cntCycle <= 8'd1;
	else if(mode == 2'd2)
			cntCycle <= 8'd4;
   else if(mode == 2'd3)
			cntCycle <= 8'd10;
end
//===================================================================
reg [7:0] cnt8;
always @(posedge clk or negedge reset_n) begin
	if (!reset_n) begin
		cnt8 <= 2'd0;
	end
	else if(state == 2'd2)
			cnt8 <= 8'd0;
	else if(state == 2'd1)
		   cnt8 <= cnt8 + 8'd1;
end
//===================================================================
reg [15:0] sampleCnt;
always @(posedge clk or negedge reset_n) begin
	if (!reset_n)
		sampleCnt <= 16'd0;
	else if((state == 2'd2)&&(cnt16 == sampleCnt))
	begin
		case(mode)
		2'd1:
		begin
			sampleCnt <= sampleCnt1MhzHalf;
		end
		2'd2:
		begin
			if(sampleCnt == sampleCnt10MhzMax)
				sampleCnt <= 16'd0;
			else begin
				sampleCnt <= sampleCnt + sampleCnt10MhzStep;
			end
		end
		2'd3:
		begin
			if(sampleCnt == sampleCnt200MhzMax)
				sampleCnt <= 16'd0;
			else begin
				sampleCnt <= sampleCnt + sampleCnt200MhzStep;
			end
		end
		endcase
	end
end
//===================================================================
reg adcClk_r;
always @(posedge clk or negedge reset_n) begin
	if (!reset_n)
		adcClk_r <= 1'd0;
	else if(mode == 2'd1)
	begin
		if((state == 2'd2) && (cnt16 == sampleCnt))
			adcClk_r <= !adcClk_r;
	end 
	else if(mode == 2'd2)
	begin
		if((state == 2'd2)&&(cnt16 == sampleCnt))
			adcClk_r <= 1'd1;
		else if((state == 1'd1) && (cnt8 == 8'd3))
			adcClk_r <= 1'd0;
	end
	else if(mode == 2'd3)
	begin
		if((state == 2'd2)&&(cnt16 == sampleCnt))
			adcClk_r <= 1'd1;
		else if((state == 1'd1) && (cnt8 == 8'd6))
			adcClk_r <= 1'd0;
	end
end
//===================================================================
reg adcClk_r2;
always @(posedge clk or negedge reset_n) begin
	if (!reset_n)
		adcClk_r2 <= 1'd0;
	else 
		adcClk_r2 <= adcClk_r;
end
//===================================================================

//===================================================================
reg[7:0] adcData_r;
always @(posedge adcClk_r or negedge reset_n) begin
	if (!reset_n) begin
		// reset
		adcData_r <= 0;
	end
	else adcData_r <= adcData;
end
//===================================================================
reg trigFlag;
always @(posedge adcClk_r or negedge reset_n) begin
	if (!reset_n) begin
		trigFlag <= 0;
	end
	else if(adcData >= (trig - 12) && adcData_r < (trig - 12))
		trigFlag <= 1;
	else
		trigFlag <= 0;
end
//===================================================================
reg ramWrState;
always @(posedge adcClk_r or negedge reset_n) begin
	if (!reset_n)
		ramWrState <= 1'd0;
	else 
	begin
		case(ramWrState)
			1'd0:
			begin
				if(!busy && trigFlag)
					ramWrState <= 1'd1;
				else begin
					ramWrState <= 1'd0;
				end
			end
			1'd1:
			begin
				if(ramWrCnt == 8'd200)
					ramWrState <= 1'd0;
				else begin
					ramWrState <= 1'd1;
				end
			end
		endcase
	end
end
//===================================================================
reg [7:0] ramWrCnt;
always @(posedge adcClk_r or negedge reset_n) begin
	if (!reset_n)
		ramWrCnt <= 8'd0;
	else if(ramWrState == 1'd1)
	begin
		if(ramWrCnt == 8'd200)
			ramWrCnt <= 8'd0;
		else begin
			ramWrCnt <= ramWrCnt + 8'd1;
		end
	end
end

//===================================================================
reg ramWrEn;
always @(posedge adcClk_r or negedge reset_n) begin
	if (!reset_n)
		ramWrEn <= 1'd0;
	else if (ramWrState == 1'd1)
		ramWrEn <= 1'd1;
	else begin
		ramWrEn <= 1'd0;
	end
end
//===================================================================
reg readS;
always @(posedge adcClk_r or negedge reset_n) begin
	if (!reset_n)
		readS <= 1'd0;
	else 
   begin
    if((ramWrState == 1'b1) && (ramWrCnt == 8'd200))
	    begin
		 readS <= 1'd1;
		 led2 <= 1'd1;
		 end
	else begin
		 readS <= 1'd0;
		 led2 <= 1'd0;
	     end
	end
end
//===================================================================
endmodule
