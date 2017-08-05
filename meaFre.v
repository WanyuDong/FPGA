// MeaFre

module meaFre(
	input 		 clk,rst,
	input 		 bitIn,
	output       start,
	output[15:0] cntFre 
);
//========================================
assign cntFre = cntFre_rr[15:0];
assign start = start_r;
//=========================================
reg [4:0] bitIn_r;
always @(posedge clk or negedge rst) begin
	if (!rst) begin
		// reset
		bitIn_r <= 5'd0;
	end
	else begin
		bitIn_r <= {bitIn_r[3:0],bitIn};
	end
end
//=========================================
reg state;
always @(posedge clk or negedge rst) begin
	if (!rst) begin
		// reset
		state <= 1'd0;
	end
	else begin
	case(state)
		1'd0:
		begin
			if (bitIn_r[3] && !bitIn_r[4]) begin
				state <= 1'd1;
			end
			else begin
				state <= 1'd0;
			end
		end
		1'd1:
		begin
			if (!bitIn_r[3] && bitIn_r[4]) begin
				state <= 1'd0;
			end
			else begin
				state <= 1'd1;
			end
		end
	endcase 
	end
end
//=========================================
reg[31:0] cnt32;
always @(posedge clk or negedge rst) begin
	if (!rst) begin
		// reset
		cnt32 <= 32'd0;
	end
	else if(state == 1'd1)begin
		cnt32 <= cnt32 + 32'd1;
	end
	else if(state == 1'd0)begin
		cnt32 <= 32'd0;
	end
end
//=========================================
reg[31:0] cntFre_r;
always @(posedge clk or negedge rst) begin
	if (!rst) begin
		// reset
		cntFre_r <= 32'd1000;
	end
	else if((state == 1'd1) && !bitIn_r[3] && bitIn_r[4])begin
		cntFre_r <= cnt32;
	end
	else if(state == 1'd0)begin
		cntFre_r <= cntFre_r;
	end
end
//=========================================
reg[15:0] cntFre_rr;
always @(posedge clk or negedge rst) begin
	if (!rst) begin
		// reset
		cntFre_rr <= 16'd500;
	end
	else if(cntFre_r < 32'd1005 && cntFre_r > 32'd830)begin
		cntFre_rr <= cntFre_r[15:0] + 16'd0;
	end
end
//=========================================
reg start_r;
always @(posedge clk or negedge rst) begin
	if (!rst) begin
		// reset
		start_r <= 1'd0;
	end
	else if(cnt32 == 32'd0)begin
		start_r <= !start_r;
	end
end
//=========================================
endmodule

