//rxd_control

module uart_rxd_ctr(
				input 	     clk,
				input 	   	rst,
				input	      rx_done,
				input [7:0]rx_data_in,
				output reg[7:0]   divNum,
				output reg[15:0]   adjNum
				);

//===========================================
reg[7:0] rx_data;
always @(posedge clk or negedge rst) begin
	if (!rst) begin
		// reset
		rx_data <= 8'd0;
	end
	else if (rx_done) begin
		rx_data <= rx_data_in;
	end
end
//============================================
reg[8:0]rxState;
reg[7:0]cnt8;
reg[7:0]divNum_r;
reg[15:0]adjNum_r;

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		// reset
		rxState <= 9'd0;
		divNum <= 8'd124;
		adjNum <= 16'hffff;
		divNum_r <= 8'd0;
		adjNum_r <= 16'd0;
	end
	else if(rx_done)begin
		case(rxState)
			9'd0:
			begin
				if(rx_data == 8'hff) begin
					rxState <= 9'd1;
				end
				else begin
					rxState <= 9'd0;
				end
			end
			9'd1:
			begin
				if(rx_data == 8'hf0) begin
					rxState <= 9'd2;
				end
				else begin
					rxState <= 9'd0;
				end
			end
			9'd2:
			begin
				if(rx_data == 8'ha0) begin
					rxState <= 9'd3;
				end
				else begin
					rxState <= 9'd0;
				end
			end
			9'd3:
			begin
				divNum_r <= rx_data;
				rxState <= 9'd4;
			end
			9'd4:
			begin
				adjNum_r[15:8] <= rx_data - 8'd1;
				rxState <= 9'd5;
			end
			9'd5:
			begin
				adjNum_r[7:0] <= rx_data - 8'd1;
				rxState <= 9'd6;
			end
			9'd6:
			begin
				if(rx_data == 8'h0d) begin
					rxState <= 9'd7;
				end
				else begin
					rxState <= 9'd0;
				end
			end
			9'd7:
			begin
				if(rx_data == 8'h0a) begin
					rxState <= 9'd8;
				end
				else begin
					rxState <= 9'd0;
				end
			end
			9'd8:
			begin
				divNum <= divNum_r;
				if(adjNum_r == 16'hfefe) begin
					adjNum <= 16'hffff;
				end
				else begin
					adjNum <= adjNum_r;
				end
				rxState <= 9'd0;
			end
		endcase
	end
end

endmodule

