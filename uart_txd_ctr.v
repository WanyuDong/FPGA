module uart_txd_ctr(
	input clk_uart,rst,
	input start,
	input txBusy,
	input [15:0]sync_fre,

	output [7:0]txData,
	output txPos

	);
//===================================================================

assign  txData = txDataT[7:0];
assign  txPos = txPos_t;

//===================================================================
reg start_r;
always @(posedge clk_uart or negedge rst) begin
	if (!rst) begin
		// reset
		start_r <= 0;
	end
	else 	start_r <= start;
end
//===================================================================

reg [1:0] SendState;
reg [7:0] txDataCnt,SendCnt;
reg [7:0] txDataT;
reg txPos_t;
always @(posedge clk_uart or negedge rst) begin
	if (!rst) begin
		// reset
	  SendState <= 2'd0;
	  SendCnt <= 8'd0;
	end
	else
	begin
		case(SendState)
			2'd0:
			begin
			    if(start_r && !start)
					SendState <= 2'd1;
			    else
					SendState <= 2'd0;	
			 end
			2'd1:
			begin if(!txBusy) begin
						if(txDataCnt == 8'd7)
						begin
								SendState <= 2'd0;
								txDataCnt <= 8'd0;
						end
						else begin
								txDataCnt <= txDataCnt + 8'd1;
								txPos_t <= 1'd1;
								txDataT <= txDataT_r;
								SendState <= 2'd2;
								if((txDataCnt > 8'd1) && (txDataCnt <= 8'd3))
										SendCnt <= SendCnt + 8'd1;
								else
										SendCnt <= 8'd0;
						end
					end
			 end
			2'd2:
			begin
					txPos_t <= 1'd0;
					SendState <= 2'd1;
			 end
		endcase
	end
end
//===================================================================
reg [7:0] txDataT_r;
always @(posedge clk_uart or negedge rst) begin
	if (!rst) begin
		txDataT_r <= 8'hff;
	end
	else 
	begin
	 if(txDataCnt == 8'd0)
				txDataT_r <= 8'hff;
	 else if(txDataCnt == 8'd1)
				txDataT_r <= 8'hf0;
	 else if(txDataCnt == 8'd2)
		        txDataT_r <= 8'ha0;
	 else if(txDataCnt == 8'd3)
				txDataT_r <= sync_fre[15:8];
	 else if(txDataCnt == 8'd4)
				txDataT_r <= sync_fre[7:0];
	 else if(txDataCnt == 8'd5)
				txDataT_r <= 8'h0d;
	 else if(txDataCnt == 8'd6)
	 			txDataT_r <= 8'h0a;
	 else txDataT_r <= 8'd0;
	end
end
//===================================================================
endmodule
