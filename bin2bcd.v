//bin - bcd

module bin2bcd(
	input clk,rst,
	input [15:0] binary,
	output[3:0] W,
	output[3:0] Q,
	output[3:0] B,
	output[3:0] S,
	output[3:0] G
	);
//==========================================
assign W = bcd_c[19:16];
assign Q = bcd_c[15:12];
assign B = bcd_c[11:8];
assign S = bcd_c[7:4];
assign G = bcd_c[3:0];
//==========================================
reg[19:0] bcd,bcd_c;
reg[15:0] bin;
reg[7:0] cnt8;
reg[2:0]state;

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		// reset
	end
	else 
	case(state)
		3'd0:
		begin
				bin <= binary;
				state <= 3'd1;
		end
		3'd1:
		begin
			if(bcd[3:0] >= 4'd5)begin
				bcd[3:0] <= bcd[3:0] + 4'd3;
			end
			if(bcd[7:4] >= 4'd5)begin
				bcd[7:4] <= bcd[7:4] + 4'd3;
			end
			if(bcd[11:8] >= 4'd5)begin
				bcd[11:8] <= bcd[11:8] + 4'd3;
			end
			if(bcd[15:12] >= 4'd5)begin
				bcd[15:12] <= bcd[15:12] + 4'd3;
			end
			if(bcd[19:16] >= 4'd5)begin
				bcd[19:16] <= bcd[19:16] + 4'd3;
			end
			state <= 3'd2;
		end
		3'd2:
		begin
			{bcd,bin} <= {bcd,bin} << 1'b1;
			cnt8 <= cnt8 + 8'd1;
			state <= 3'd3;
		end
		3'd3:
		begin
			if(cnt8 == 8'd16)begin
				state <= 3'd4;
			end
			else begin
				state <=3'd1;
			end
		end
		3'd4:
		begin
			bcd_c <= bcd;
			bcd   <= 20'd0;
			cnt8  <= 8'd0;
			state <= 3'd0;
		end
	endcase

end

endmodule


