//sinc

module sinc2(
	input clk_fs,clk_Mfs,rst,
	input binIn,
	input[1:0] mode,
	output[15:0]DATA
	);
//===========================================
assign DATA = data[15:0];
//===========================================
reg[16:0]binIn_d;
always @(posedge clk_Mfs or negedge rst) begin
	if (!rst) begin
		// reset
		binIn_d <= 1'd0;
	end
	else if(binIn)begin
		binIn_d <= 17'd1;
	end
	else begin
		binIn_d <= 17'd0;
	end
end
//===========================================
reg[16:0] add1,add2;
always @(posedge clk_Mfs or negedge rst) begin
	if (!rst) begin
		// reset
		add1 <= 17'd0;
	end
	else begin
		add1 <= add1 + binIn_d;
		add2 <= add2 + add1;
	end
end
//=============================================
reg[16:0] diff1,diff2,add2_d1,add2_d2,diff1_d;
always @(posedge clk_fs or negedge rst) begin
	if (!rst) begin
		// reset
		diff1 <= 17'd0;
		diff2 <= 17'd0;
		diff1_d <= 17'd0;
		add2_d1 <= 17'd0;
		add2_d2 <= 17'd0;
	end
	else begin
		add2_d1  <= add2;
		add2_d2  <= add2_d1;
		diff1_d <= diff1;

		diff1 <= add2_d1 - add2_d2;
		diff2 <= diff1 - diff1_d;
	end
end
//=============================================
reg[15:0] data;
always @(posedge clk_fs or negedge rst) begin
	if (!rst) begin
		// reset
		data <= 16'd0;
	end
	else begin
		case(mode)
			2'd0:data <= {4'd0,diff2[11:0]};
			2'd1:data <= {8'd0,diff2[8:0]};
			2'd2:data <= diff2[15:0];
			2'd3:data <= diff2[15:0];
			default:data <= 16'd888;
		endcase
	end
end
//=============================================

endmodule

